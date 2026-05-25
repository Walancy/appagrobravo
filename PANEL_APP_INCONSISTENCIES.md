# ANÁLISE DE INCONSISTÊNCIAS — Painel vs App Viajante
**Data:** 2026-05-25 | **Método:** Análise cruzada de código (Next.js painel + Flutter app)
**Painel:** `/home/ideasprosolus/agrobravo-painel/appmoove-agrobravo-painel`
**App:** `/home/ideasprosolus/agrobravo-app-viajante/appagrobravo`

---

## RESUMO EXECUTIVO

| Criticidade | Qtd | Impacto principal |
|-------------|-----|-------------------|
| Critical    | 4   | Dados criados no painel que o viajante nunca vê ou recebe errado |
| High        | 7   | Funcionalidades do painel sem correspondência no app |
| Medium      | 8   | Campos ignorados, classificações erradas, gaps de UX |
| Low         | 5   | Campos financeiros expostos, dead-code, naming |
| **Total**   | **24** | |

---

## INCONSISTÊNCIAS CRITICAL

---

### INC-001 — Módulo de Materiais do painel não existe no app
**Painel:** `grupos/[id]` → aba "Materiais" | `materialsService.ts`
**App:** nenhum módulo

**O que o painel faz:**
- Admin faz upload de PDFs, guias, documentos por grupo
- Cada material tem status: "Visível" ou "Oculto"
- Materiais visíveis são destinados ao viajante

**O que o app faz:**
- Nada. Tabela `materiais` nunca é consultada no app.

**Impacto:** O viajante nunca recebe os materiais que o admin preparou (guias de viagem, PDFs de documentação, instruções). Funcionalidade completamente morta do lado do app.

**Solução:** Criar aba/seção "Materiais" no app consultando a tabela `materiais` com filtro `status = 'Visivel'` e `grupo_id`.

---

### INC-002 — Eventos têm `passageiros[]` mas o app mostra todos os eventos do grupo para todos
**Painel:** campo `passageiros: string[]` (array de user_ids) por evento
**App:** `itinerary_repository_impl.dart:65` → `.eq('grupo_id', groupId)` sem filtrar passageiros

**O que o painel faz:**
- Admin pode atribuir um evento apenas para um subconjunto de passageiros do grupo
- Ex: evento de voo apenas para parte do grupo, refeição opcional para quem se inscreveu
- Campo `passageiros[]` no banco armazena quais user_ids participam daquele evento

**O que o app faz:**
- Mostra TODOS os eventos do grupo para o viajante, independente de estar em `passageiros[]`

**Impacto:** Viajante vê eventos que não são para ele. Ou — dependendo da modelagem — eventos criados para outros passageiros aparecem no seu itinerário.

**Solução:** Adicionar filtro na query ou RPC para retornar apenas eventos onde `passageiros` contém o `user_id` do usuário logado, OU onde `passageiros` está vazio (evento para todos).

---

### INC-003 — Push notifications não chegam ao viajante (FCM não configurado no app)
**Painel:** `notificationsService.ts` → cria registros em `notificacoes` + envia FCM push via `fcm_token`
**App:** nenhum código de registro de FCM token encontrado

**O que o painel faz:**
- Quando admin cria/edita evento com `notify_participants: true`, o painel:
  1. Cria registros em `notificacoes` para cada participante
  2. Lê o `fcm_token` do `users` do participante
  3. Envia push notification via Firebase Cloud Messaging

**O que o app faz:**
- Tabela `users` tem coluna `fcm_token` mas o app nunca grava este valor
- App carrega notificações apenas sob demanda (pull manual na tela de notificações)
- Sem push: viajante não é alertado de nenhuma alteração de itinerário em tempo real

**Impacto:** Viajante não recebe alertas quando:
- Admin cria novo evento
- Evento é alterado (horário, local, etc.)
- Evento é cancelado
- Qualquer notificação gerada pelo painel

**Solução:**
1. Integrar `firebase_messaging` no app
2. No login/startup: obter token FCM e salvar em `users.fcm_token`
3. Configurar handler de mensagens em foreground e background

---

### INC-004 — Sem real-time: alterações do painel não chegam ao app sem refresh manual
**Painel:** usa Supabase real-time implicitamente via React Query + revalidação
**App:** carrega dados uma única vez, nenhuma subscription ativa

**O que o painel faz:**
- Qualquer colaborador pode modificar itinerário a qualquer momento
- Horários, locais e até tipo de evento podem mudar durante a viagem

**O que o app faz:**
- `loadUserItinerary()` é chamado apenas no `initState` e no `pull-to-refresh`
- Se admin muda evento enquanto viajante está com o app aberto: viajante vê dado desatualizado até fechar e reabrir o app

**Impacto:** Viajante pode ir ao local errado, no horário errado, por não receber update em tempo real.

**Solução:**
```dart
// Em ItineraryCubit: adicionar subscription Supabase real-time
_supabaseClient
  .from('eventos')
  .stream(primaryKey: ['id'])
  .eq('grupo_id', groupId)
  .listen((_) => loadItinerary(groupId));
```

---

## INCONSISTÊNCIAS HIGH

---

### INC-005 — `hotelData` JSONB: informações ricas de hotel perdidas no app
**Painel:** eventos de hotel armazenam em `dados` JSONB: `amenities[]`, `description`, `thumbnail`, `reviews`, `overall_rating`
**App:** `itinerary_item_dto.dart:213` → `transportMode: dados?['transportMode']` — só lê `transportMode`

**O que o painel registra no `dados`:**
```json
{
  "transportMode": "driving",
  "amenities": ["Wi-Fi", "Café da manhã", "Piscina"],
  "description": "Hotel boutique no centro histórico",
  "thumbnail": "https://...",
  "overall_rating": 4.7,
  "reviews": 342,
  "planeType": "Boeing 737"
}
```

**O que o app lê:** apenas `transportMode`. Todo o restante é silenciosamente descartado.

**Impacto:** Amenidades do hotel, descrição, thumbnail específico do fornecedor e nota de avaliação nunca chegam ao viajante mesmo existindo no banco.

**Solução:** Extrair campos relevantes do `dados` JSONB no DTO:
```dart
amenities: (dados?['amenities'] as List?)?.cast<String>(),
hotelDescription: dados?['description'] as String?,
planeType: dados?['planeType'] as String?,
```

---

### INC-008 — `status` da missão ignorado: app usa só `endDate` para detectar missão encerrada
**Painel:** `missoes.status` → `'Planejado' | 'Em andamento' | 'Finalizado'`
**App:** `itinerary_page.dart:44` → `group.endDate.isBefore(DateTime.now())`

**O que o painel faz:**
- Admin pode marcar missão como "Finalizado" antes do `endDate`
- Admin pode marcar como "Planejado" (ainda não iniciado) mesmo com datas no futuro

**O que o app faz:**
- Sempre compara apenas com a data atual vs `endDate`
- Se admin cancela a missão e marca como "Finalizado" 3 dias antes do previsto: app ainda mostra como ativa

**Impacto:** Viajante vê status errado da missão. Um cancelamento pelo painel nunca reflete no app.

**Solução:** Incluir `status` na query de `grupos` + `missoes` e usar como critério primário.

---

### INC-010 — `attachments` em eventos do painel invisíveis no app
**Painel:** cada evento pode ter `attachments: [{ name, url }]` — PDFs, imagens adicionais
**App:** campo não existe em `ItineraryItemDto` nem em `ItineraryItemEntity`

**O que o painel registra:**
- Mapa do local, cardápio do restaurante, boarding pass, voucher de hotel em PDF

**Impacto:** Documentos críticos por evento são totalmente invisíveis ao viajante.

**Solução:** Adicionar `attachments` ao DTO/entity e renderizar lista de links para download no `GenericEventCard`.

---

### INC-011 — `foiNotificado` em `gruposParticipantes` nunca atualizado pelo app
**Painel:** `gruposParticipantes.foiNotificado` → boolean que controla se participante foi notificado da adição
**App:** campo nunca lido nem gravado

**O que o painel usa:**
- Painel lista participantes ainda não notificados para o admin poder reenviar convite
- Admin vê badge "Não notificado" para usuários com `foiNotificado: false`

**Impacto:** Todo viajante aparece como "não notificado" no painel mesmo depois de ter recebido e lido a notificação no app.

---

## INCONSISTÊNCIAS MEDIUM

---

### INC-012 — Classificação de tipo de notificação do painel é frágil e pode errar
**Painel:** envia notificações com `tipo: 'missionUpdate'`, `titulo`, `mensagem`
**App:** `notification_model.dart:37-87` → classifica tipo por parsing de texto (`assunto`, `titulo`, `mensagem`)

**Problema:** Painel usa campo `tipo` mas o app usa `assunto` (que é o mesmo valor). Notificações do painel com `titulo` contendo a palavra "guia" são classificadas como `guideAlert` mesmo quando são apenas atualizações genéricas. Ex: "Seu guia turístico estará no lobby às 8h" → classificado como `guideAlert` ao invés de `missionUpdate`.

**Impacto:** Ícone e agrupamento errados na tela de notificações.

**Solução:** Usar o campo `tipo` como fonte primária de classificação, com fallback para parsing de texto.

---

### INC-013 — `deleted_at` (soft delete) não filtrado na query de eventos
**Painel:** usa soft delete (`deleted_at IS NOT NULL`) em eventos, grupos e usuários
**App:** `itinerary_repository_impl.dart:64` → `.select().eq('grupo_id', groupId)` sem `.is_('deleted_at', null)`

**Impacto:** Se RLS do Supabase não filtrar por `deleted_at`, eventos excluídos pelo painel continuam aparecendo no itinerário do viajante.

**Solução:**
```dart
.from('eventos')
.select()
.eq('grupo_id', groupId)
.isFilter('deleted_at', null)  // garantir exclusão de soft-deletes
```

---

### INC-014 — Transfer `transfer_data`/`transfer_hora` não extraídos no DTO
**Painel:** eventos de voo geram transfer com campos separados `transfer_data` e `transfer_hora` (hora de pickup real, que pode diferir do `hora_inicio` do evento)
**App:** `ItineraryItemDto` não mapeia esses campos — usa `hora_inicio` como horário do transfer

**Impacto:** Viajante pode ver horário errado para o transfer de pickup no aeroporto.

---

### INC-016 — `primeiroacesso: true` não detectado — sem onboarding para novos usuários
**Painel:** invita usuários com `primeiroacesso: true` — indica usuário recém-chegado ao sistema
**App:** auth flow não diferencia primeiro acesso de acesso regular

**O que o painel espera:** após primeiro login, usuário deve completar perfil, ver tutorial, entender o app
**O que o app faz:** leva direto para a home sem nenhuma diferenciação

**Impacto:** Viajante recém-convidado pelo admin chega ao app sem orientação — não sabe onde estão os recursos, não recebe prompt para completar perfil.

---

### INC-018 — `place_id` do Google não aproveitado para deep links de mapa
**Painel:** salva `place_id` (Google Places ID) em eventos de visita, hotel, restaurante
**App:** usa `lat/lon` ou `link_maps` para abrir mapa, ignora `place_id`

**Impacto:** Deep link `https://www.google.com/maps/place/?q=place_id:ChIJ...` abre diretamente o local correto no Google Maps com avaliações e fotos — mais confiável do que busca por coordenadas ou query de texto.

---

### INC-019 — `ItineraryPage` (deep link) sem filtros, `ItineraryTab` com filtros
**App:** duas implementações separadas do mesmo conteúdo:
- `itinerary_tab.dart` → filtros por tipo e horário ✅
- `itinerary_page.dart` → sem filtros, sem banner de documentos pendentes ❌

**Impacto:** Viajante que chega via deep link (`/itinerary/:groupId`) tem experiência degradada — sem filtros e sem avisos de documentos.

---

## INCONSISTÊNCIAS LOW

---

### INC-020 — `percent_agrobravo`/`percent_cliente` expostos ao app (dado sensível)
**Painel:** eventos têm campos `percent_agrobravo` e `percent_cliente` (divisão de receita comercial)
**App:** query `select()` sem restrição de colunas — esses campos chegam ao device do viajante

**Impacto:** Dados de margem comercial da Agrobravo ficam no payload do app. Se o app for inspecionado (proxy, debug), o viajante pode ver a markup. Recomendado restringir via RLS no Supabase.

---

### INC-023 — `itinerary_tab.dart` possui método `_isSameDay` nunca utilizado (dead code)
**Arquivo:** `lib/features/itinerary/presentation/pages/itinerary_tab.dart:279`
Duplicata do `_isSameDay` que também existe em `itinerary_list.dart`. Nunca chamado em `_ItineraryContentState`.

---

### INC-024 — DB ordering de `hora_inicio` pode ser string sort (9:00 > 10:00)
**App:** `itinerary_repository_impl.dart:67` → `.order('hora_inicio')` — campo é `text` no DB
**Impacto:** String sort ordena `"9:00"` após `"10:00"` (porque '9' > '1'). O app re-ordena em memória com `_buildOrderedItems`, então não há impacto visual. Mas a query retorna dados em ordem errada — desnecessário e potencialmente confuso para debug.

**Solução:** Fazer ordering apenas em memória (já feito), ou garantir que `hora_inicio` no DB seja `TIME` e não `TEXT`.

---

## PRIORIZAÇÃO DE IMPLEMENTAÇÃO

### Fase 1 — Impacto imediato (sprint atual)
1. **INC-001** — Módulo de materiais por grupo
2. **INC-003** — Integração FCM para push notifications
3. **INC-006** — Badge `free` no evento
4. **INC-013** — Filtro `deleted_at IS NULL` na query de eventos

### Fase 2 — Completude de dados (próximo sprint)
5. **INC-002** — Filtrar eventos por `passageiros[]`
6. **INC-004** — Real-time subscription de eventos
7. **INC-005** — Extrair `hotelData` e demais campos do JSONB `dados`
8. **INC-007** — Exibir voucher do participante no perfil
9. **INC-009** — Fallback para `missoesParticipantes` no `getUserGroupId`
10. **INC-010** — Renderizar attachments de eventos

### Fase 3 — Qualidade e refinamento
11. **INC-008** — Usar `status` real da missão
12. **INC-012** — Classificação de notificação por campo `tipo`
13. **INC-014** — Extrair `transfer_data`/`transfer_hora` no DTO
14. **INC-016** — Detectar `primeiroacesso` e exibir onboarding
15. **INC-018** — Usar `place_id` para deep links do Maps
16. **INC-019** — Unificar `ItineraryPage` e `ItineraryTab`

---

*Documento gerado por análise estática cruzada — 2026-05-25*
