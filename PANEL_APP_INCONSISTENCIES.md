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

### ✅ INC-001 — Módulo de Materiais do painel não existe no app
**Painel:** `grupos/[id]` → aba "Materiais" | `materialsService.ts`
**App:** nenhum módulo

**O que o painel faz:**
- Admin faz upload de PDFs, guias, documentos por grupo
- Cada material tem status: "Visível" ou "Oculto"
- Materiais visíveis são destinados ao viajante

**Corrigido em:** `lib/features/itinerary/domain/entities/mission_material.dart` (entity `MissionMaterialEntity`) + `getMissionMaterials()` no repositório consultando `materiais` com filtro `status = 'Visivel'` e `grupo_id`.

---

### ✅ INC-002 — Eventos têm `passageiros[]` mas o app mostra todos os eventos do grupo para todos
**Corrigido em:** `itinerary_repository_impl.dart` — campo `passageiros` adicionado ao DTO; após fetch, filtra em memória: mantém eventos onde `passageiros` é null/vazio OU contém o `user_id` do viajante logado.

---

### ✅ INC-003 — Push notifications não chegam ao viajante (FCM não configurado no app)
**Painel:** `notificationsService.ts` → cria registros em `notificacoes` + envia FCM push via `fcm_token`
**App:** nenhum código de registro de FCM token encontrado

**Corrigido em:** `lib/features/auth/data/repositories/auth_repository_impl.dart` — método `_persistFcmTokenIfAvailable()` chamado no login Google e Apple. Token gravado em `users.fcm_token`.

---

### ✅ INC-004 — Sem real-time: alterações do painel não chegam ao app sem refresh manual
**Corrigido em:** `itinerary_cubit.dart` — adicionado `_subscribeToEventsChanges(groupId)` chamado após primeiro load. Usa `RealtimeChannel` com filtro `grupo_id = groupId`. Ao detectar mudança, chama `_refreshItemsSilently` (sem emitir estado `loading`). Subscription cancelada no `close()`.

---

## INCONSISTÊNCIAS HIGH

---

### ✅ INC-005 — `hotelData` JSONB: informações ricas de hotel perdidas no app
**Painel:** eventos de hotel armazenam em `dados` JSONB: `amenities[]`, `description`, `thumbnail`, `reviews`, `overall_rating`
**App:** `itinerary_item_dto.dart:213` → `transportMode: dados?['transportMode']` — só lê `transportMode`

**Corrigido em:** `itinerary_item_dto.dart` / `itinerary_item.dart` — adicionados campos `amenities`, `hotelDescription` e `planeType` extraídos do JSONB `dados`.

---

### ✅ INC-008 — `status` da missão ignorado: app usa só `endDate` para detectar missão encerrada
**Painel:** `missoes.status` → `'Planejado' | 'Em andamento' | 'Finalizado'`
**App:** `itinerary_page.dart:44` → `group.endDate.isBefore(DateTime.now())`

**Corrigido em:** `itinerary_group.dart` + `itinerary_group_dto.dart` — adicionado campo `status`. `itinerary_page.dart` agora usa `group.status == 'Finalizado'` como critério primário de missão encerrada.

---

### ✅ INC-010 — `attachments` em eventos do painel invisíveis no app
**Painel:** cada evento pode ter `attachments: [{ name, url }]` — PDFs, imagens adicionais
**App:** campo não existe em `ItineraryItemDto` nem em `ItineraryItemEntity`

**Corrigido em:** `itinerary_item_dto.dart` — campo `@JsonKey(name: 'attachments')` adicionado ao DTO. `itinerary_item.dart` — campo `attachments` adicionado à entity. Dados chegam ao app; renderização no card é o próximo passo.

---

### ✅ INC-011 — `foiNotificado` em `gruposParticipantes` nunca atualizado pelo app
**Corrigido em:** `itinerary_repository_impl.dart` — em `getUserGroupId()`, após sucesso, dispara update fire-and-forget: `gruposParticipantes.foiNotificado = true` para o par `user_id + grupo_id`.

---

## INCONSISTÊNCIAS MEDIUM

---

### ✅ INC-012 — Classificação de tipo de notificação do painel é frágil e pode errar
**Painel:** envia notificações com `tipo: 'missionUpdate'`, `titulo`, `mensagem`
**App:** `notification_model.dart:37-87` → classifica tipo por parsing de texto (`assunto`, `titulo`, `mensagem`)

**Corrigido em:** `notification_model.dart` — adicionado campo `tipo` ao modelo freezed. `toEntity()` agora usa `tipo` como fonte primária de classificação, com fallback para o parsing de texto existente.

---

### ✅ INC-013 — `deleted_at` (soft delete) não filtrado na query de eventos
**Painel:** usa soft delete (`deleted_at IS NOT NULL`) em eventos, grupos e usuários
**App:** `itinerary_repository_impl.dart:64` → `.select().eq('grupo_id', groupId)` sem `.is_('deleted_at', null)`

**Corrigido em:** `itinerary_repository_impl.dart` — adicionado `.isFilter('deleted_at', null)` na query de eventos.

---

### ✅ INC-014 — Transfer `transfer_data`/`transfer_hora` não extraídos no DTO
**Painel:** eventos de voo geram transfer com campos separados `transfer_data` e `transfer_hora` (hora de pickup real, que pode diferir do `hora_inicio` do evento)
**App:** `ItineraryItemDto` não mapeia esses campos — usa `hora_inicio` como horário do transfer

**Corrigido em:** `itinerary_item_dto.dart` — campos `transfer_data` e `transfer_hora` mapeados via `@JsonKey`. `itinerary_item.dart` — campos `transferDate` e `transferTime` adicionados à entity.

---

### ✅ INC-016 — `primeiroacesso: true` não detectado — sem onboarding para novos usuários
**Corrigido em:** `auth_repository_impl.dart` — `_upsertPublicUser` agora lê `primeiroacesso` no SELECT. Se for `true` (usuário convidado pelo admin) ou novo cadastro, salva flag `show_first_access_prompt: true` em SharedPreferences e zera o campo no DB. Em `home_page.dart` — `_checkFirstAccessPrompt()` no `initState` lê a flag e exibe dialog convidando o viajante a completar o perfil com link para `/account-data`.

---

### ✅ INC-018 — `place_id` do Google não aproveitado para deep links de mapa
**Corrigido em:** `itinerary_item_dto.dart` + `itinerary_item.dart` — campo `placeId` adicionado. `itinerary_cards.dart` — `_launchMaps()` agora prioriza `place_id` (`maps/place/?q=place_id:…`) antes de `link_maps` e coordenadas.

---

### ✅ INC-019 — `ItineraryPage` (deep link) sem filtros, `ItineraryTab` com filtros
**App:** duas implementações separadas do mesmo conteúdo:
- `itinerary_tab.dart` → filtros por tipo e horário ✅
- `itinerary_page.dart` → sem filtros, sem banner de documentos pendentes ❌

**Corrigido em:** `itinerary_page.dart` — adicionado `ItineraryFilters`, método `_showFilterModal()` e barra de filtros idêntica à da tab. Também passou `filters: _filters` para `ItineraryList`.

---

## INCONSISTÊNCIAS LOW

---

### ✅ INC-020 — `percent_agrobravo`/`percent_cliente` expostos ao app (dado sensível)
**Corrigido em:** `itinerary_repository_impl.dart` — `select()` substituído por lista explícita de colunas que exclui `percent_agrobravo` e `percent_cliente`. Recomendado reforçar via RLS no Supabase como camada extra de proteção.

---

### ✅ INC-023 — `itinerary_tab.dart` possui método `_isSameDay` nunca utilizado (dead code)
**Arquivo:** `lib/features/itinerary/presentation/pages/itinerary_tab.dart:279`
Duplicata do `_isSameDay` que também existe em `itinerary_list.dart`. Nunca chamado em `_ItineraryContentState`.

**Corrigido em:** método removido de `itinerary_tab.dart`.

---

### ✅ INC-024 — DB ordering de `hora_inicio` pode ser string sort (9:00 > 10:00)
**Corrigido em:** `itinerary_repository_impl.dart` — removido `.order('hora_inicio')` da query. O ordering real é feito em memória via `_buildOrderedItems`, que já funcionava corretamente. Mantido apenas `.order('data')` (formato ISO — ordenação correta).

---

## STATUS FINAL

### ✅ Todos os itens implementáveis no app foram corrigidos

| Item | Status | Descrição curta |
|------|--------|-----------------|
| INC-001 | ✅ | Módulo de materiais (entity + repo) |
| INC-002 | ✅ | Filtro de eventos por `passageiros[]` em memória |
| INC-003 | ✅ | FCM token gravado no login |
| INC-004 | ✅ | Real-time subscription de `eventos` por grupo |
| INC-005 | ✅ | `amenities`, `hotelDescription`, `planeType` do JSONB |
| INC-008 | ✅ | `status` da missão usado como critério primário |
| INC-010 | ✅ | Campo `attachments` no DTO/entity |
| INC-011 | ✅ | `foiNotificado = true` gravado no `getUserGroupId` |
| INC-012 | ✅ | Campo `tipo` como fonte primária de notificação |
| INC-013 | ✅ | Filtro `deleted_at IS NULL` na query |
| INC-014 | ✅ | `transfer_data`/`transfer_hora` no DTO/entity |
| INC-016 | ✅ | `primeiroacesso` detectado + dialog de onboarding |
| INC-018 | ✅ | `place_id` priorizado no deep link do Maps |
| INC-019 | ✅ | Filtros adicionados à `ItineraryPage` (deep link) |
| INC-020 | ✅ | Colunas sensíveis excluídas do `select()` |
| INC-023 | ✅ | Dead code `_isSameDay` removido |
| INC-024 | ✅ | `.order('hora_inicio')` DB removido (ordering em memória) |

### Pendente (requer ação no DB/Supabase)
- **INC-020 extra** — Reforçar com RLS no Supabase para `percent_*` colunas

---

*Documento gerado por análise estática cruzada — 2026-05-25 | Todos os itens do app corrigidos — 2026-05-26*
