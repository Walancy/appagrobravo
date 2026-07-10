# 🐞 QA Bug Reports — AgroBravo Viajante

| Campo | Valor |
|---|---|
| **Ciclo** | Testes estáticos / análise de código (fase 1 — sem dispositivo) |
| **Data** | 10/07/2026 |
| **App alvo** | AgroBravo Viajante (`appagrobravo`) — Flutter, Android/iOS |
| **Backend** | Supabase `dvsmadvzgowtzjbyusfz` (compartilhado com o app Guia) |
| **Método** | Mesma bateria aplicada ao app Guia (ver `QA_BUG_REPORTS.md` do repo do Guia): rastreamento de fluxos, contratos de rotas/DB/pacotes, simulação de dados legados |
| **Observação** | Este documento complementa o `QA_REPORT.md` já existente no repo (ciclo anterior). |

> ⚠️ **Estado do working tree no momento do ciclo:** havia **3 arquivos modificados não commitados** (`profile_cubit.dart`, `social_profile_page.dart`, `profile_header_cover.dart`) — o fluxo de foto do perfil social está migrando de "upload imediato" para "pendente + salvar". O ciclo testou o **working tree atual** (o que iria para o build). Re-executar os casos do módulo de fotos após o commit final.

**Estado estático:** `flutter analyze` **0 erros** · `flutter test` **3 testes falhando** (2 reais + 1 template — ver V-BUG-004).

---

## 1. Defeitos encontrados

### V-BUG-001 — Botão WhatsApp gera link com DDI duplicado (e quebra números não-BR)

| Campo | Valor |
|---|---|
| **Severidade / Prioridade** | High / **P1** |
| **Local** | `lib/features/profile/presentation/widgets/profile_actions.dart:177` |
| **Frequência** | Sempre (com telefone no formato novo `+55 ...`) |

**Idêntico ao BUG-001 do app Guia (já corrigido lá).** A tela Dados da Conta salva o telefone como `+55 (11) 98765-4321`; o botão WhatsApp faz:
```dart
final cleanPhone = phone!.replaceAll(RegExp(r'\D'), ''); // mantém o "55" do +55
final url = Uri.parse('https://wa.me/55$cleanPhone');    // wa.me/5555... ← duplicado
```
- BR novo → `wa.me/5555...` (inválido).
- Estrangeiro (`+1 ...`) → `wa.me/551...` (número errado).
- Somente telefone legado sem DDI funciona por coincidência.

**Correção de referência (aplicada no Guia):** usar os dígitos como estão quando o telefone começa com `+`; prefixar `55` apenas no legado sem DDI.

---

### V-BUG-002 — Upload da foto de perfil via "Meus Dados" sobe sem extensão

| Campo | Valor |
|---|---|
| **Severidade / Prioridade** | Medium / P2 |
| **Local** | `lib/features/profile/presentation/pages/profile_tab.dart:74` + `lib/features/profile/presentation/cubit/profile_cubit.dart:90/120` |
| **Frequência** | Sempre (nesse caminho) |

O caminho novo do perfil social (`savePhotos`) já passa `'png'` fixo — **corrigido lá**. Mas o caminho do avatar em **Meus Dados** (ProfileTab) ficou para trás:
- `profile_tab.dart` cria `XFile.fromData(bytes, name: 'profile_cropped.png')` **sem `path`** → `xfile.path == ''` (verificado no fonte do `cross_file 0.3.5`).
- `updateProfilePhoto`/`updateCoverPhoto` derivam a extensão de `file.path.split('.').last` → `''` → arquivo `"<timestamp>."` no bucket `files`, content-type `application/octet-stream`.

**Correção de referência (aplicada no Guia):** helper `_fileExtension()` que usa `file.name` como fonte com fallback `'png'`.

---

### V-BUG-003 — Nacionalidade legada em texto livre é coagida silenciosamente para "Brasil"

| Campo | Valor |
|---|---|
| **Severidade / Prioridade** | High / P2 |
| **Local** | `lib/features/profile/presentation/pages/account_data_page.dart:198-205` |
| **Frequência** | Sempre, para contas com `nacionalidade` legada em texto ("Brasileira", "Americana"...) |

**Idêntico ao BUG-004 do Guia (já corrigido lá).** A tabela `users` é compartilhada e contém valores legados em texto livre. O código só faz match por código ISO com `orElse` para Brasil:
- Viajante americano com `nacionalidade = "Americana"` → dropdown mostra **Brasil** → CPF vira obrigatório → **bloqueado de salvar** sem inventar CPF.
- Se salvar, sobrescreve a coluna com `BR` → **corrupção silenciosa do dado**.

**Correção de referência (aplicada no Guia):** `_matchNationality()` — código ISO → nome do país → gentílicos comuns; sem match, deixa vazio para forçar re-seleção.

---

### V-BUG-004 — Suíte de testes permanentemente vermelha: router acoplado ao Supabase.instance

| Campo | Valor |
|---|---|
| **Severidade / Prioridade** | Medium / P2 (qualidade de processo — a suíte não serve de quality gate) |
| **Local** | `lib/core/router/app_router.dart:51-52` (`_authRefresh` top-level) |
| **Frequência** | Sempre (2 testes reais falhando + 1 template) |

**Evidência da execução:**
```
You must initialize the supabase instance before calling Supabase.instance
#3  _authRefresh (package:agrobravo/core/router/app_router.dart:52)
#7  appRouter (package:agrobravo/core/router/app_router.dart:63)
```
O `appRouter` referencia `Supabase.instance.client.auth.onAuthStateChange` na **inicialização top-level**. Qualquer teste que toque `appRouter` sem `Supabase.initialize()` explode. Resultado:
- `auth_redirection_test.dart` → "Deve exibir a tela de Nova Senha ao acessar /reset-password" e "Deve redirecionar para Nova Senha quando o AuthCubit emitir otpVerified" **falham sempre**.
- `test/widget_test.dart` → teste template de contador do Flutter, impossível de passar (o app não tem contador), falhando desde o commit inicial. **Recomendação: remover** (feito no Guia).

**Sugestões de correção (alternativas):** (a) inicializar Supabase fake/local no `setUp` dos testes; (b) injetar o stream de auth no router via abstração (como o Guia faz com `routerRefreshStream.updateStream(...)` — os testes do Guia passam).

---

### V-BUG-005 — Fluxo novo de fotos: falha no upload descarta o recorte do usuário e derruba a tela em erro

| Campo | Valor |
|---|---|
| **Severidade / Prioridade** | Medium / P2 |
| **Local** | `lib/features/profile/presentation/pages/social_profile_page.dart` (`saveProfile`) + `profile_cubit.dart` (`savePhotos`) — **código novo, não commitado** |
| **Frequência** | Sempre que o upload falhar (rede instável em viagem = cenário comum do app) |

**Passos (rastreado por código):**
1. Editar perfil > trocar avatar > recortar (fica pendente como preview) > Salvar.
2. Upload falha (sem rede / erro do storage).

**Resultado esperado:** mensagem de erro, preview pendente preservado, usuário tenta salvar de novo.

**Resultado obtido:**
- `savePhotos` faz `emit(ProfileState.error(...))` → o `state.when` da página substitui **toda a tela** por um `Text(message)` centralizado (sem retry) — o modo edição e o contexto somem.
- No retorno, `saveProfile` executa `setState { _pendingAvatar = null; _pendingCover = null; }` **incondicionalmente** → o recorte do usuário é descartado mesmo na falha.

**Sugestão:** `savePhotos` retornar `bool`/Either em vez de emitir `error` global (ou emitir estado `loaded` com flag de erro + SnackBar); só limpar os pendentes quando o retorno for sucesso.

---

### V-BUG-006 — Cropper e seletor de país hardcoded em PT num app com 3 idiomas (pt/en/es)

| Campo | Valor |
|---|---|
| **Severidade / Prioridade** | Low / P3 |
| **Local** | `lib/core/components/image_cropper_modal.dart` (255, 318, 346, 382) e `phone_field.dart` (hint "Buscar país ou código...") |

Com o app em **English ou Español**, o modal de crop exibe "Ajustar foto", "Belisque para dar zoom • Arraste para mover", "Cancelar", "Usar foto" em português. Agravante vs o Guia: o Viajante tem l10n completa com **es** — as chaves deveriam ir para os `.arb` (`app_pt/en/es.arb`).

---

### V-BUG-007 — Cores fora do brandbook remanescentes

| Campo | Valor |
|---|---|
| **Severidade / Prioridade** | Low / P3 |
| **Local** | `lib/features/auth/presentation/widgets/login_form.dart:551` e `lib/features/itinerary/presentation/widgets/itinerary_list.dart:249` |

Dois resquícios do verde antigo da marca fora do token `AppColors`:
- `login_form.dart:551` — borda de foco de input com `Color(0xFF00E676)` (verde-limão antigo) em vez de `AppColors.primary` (#679436).
- `itinerary_list.dart:249` — `Color(0xFF00BFA5)` (teal antigo) com alpha 0.5.

---

### V-BUG-008 — Dead code e logging verboso na HomePage

| Campo | Valor |
|---|---|
| **Severidade / Prioridade** | Low / P4 (manutenibilidade) |
| **Local** | `lib/features/home/presentation/pages/home_page.dart` |

- Bloco `if (_selectedIndex == -1) return CircularProgressIndicator(...)` **duplicado literalmente** (linhas ~299-310, um imediatamente após o outro) — o segundo é inalcançável.
- Na mesma builder, `isComplete` é calculado e nunca usado (variável morta).
- **9 chamadas `dev.log('[HOME] ...')`** verbosas que executam também em release (payloads de estado/grupo em log).

---

## 2. Observações / decisões pendentes (não são defeitos)

| ID | Observação | Ação sugerida |
|----|-----------|---------------|
| OBS-V1 | **`/settings` (SettingsPage, 533 linhas) é uma tela órfã**: nenhuma UI navega até ela desde que o ProfileTab (Meus Dados) a substituiu; só é alcançável por deep link. É funcionalidade duplicada que tende a divergir do Meus Dados (hoje já só tem 2 tiles de conta vs. o menu completo). | Remover a página e transformar `/settings` em redirect → `/home?tab=3` (como feito no Guia), ou assumir a manutenção dupla. |
| OBS-V2 | **`/food-preferences` é rota+página órfãs** — nenhuma tile/menu aponta para ela (o item saiu do Meus Dados). | Confirmar com o PO se preferências alimentares saíram do produto; remover ou restaurar a entrada. |
| OBS-V3 | **Trabalho em andamento não commitado** no fluxo de fotos (3 arquivos). O módulo de fotos deve ser re-testado após o commit; o V-BUG-005 refere-se a esse código novo. | Commitar/finalizar antes do ciclo em dispositivo. |
| OBS-V4 | No `notification_navigation_service`, `/notifications` mapeia para `('/home', route)` mas o comentário diz "community tab" — comportamento ok (home decide a tab), comentário desatualizado. | Ajustar comentário. |

---

## 3. Verificações que PASSARAM (evidência de código)

| Verificação | Resultado |
|---|---|
| `flutter analyze` — 0 erros no working tree atual | ✅ PASS |
| Sem diálogos/artefatos de DEBUG em fluxo de produção (diferente do Guia, que tinha 2) | ✅ PASS |
| Contrato de deep link (`fcm_deeplink_flutter.md`) **não** anuncia `/settings` — sem risco equivalente ao BUG-002 do Guia; a rota existe e responde | ✅ PASS |
| Mapeamento de tabs do `notification_navigation_service` (0=Itinerário, 1=Chat, 2=Comunidade, 3=Meus Dados) confere com a `home_page` | ✅ PASS |
| `supportedLocales` via `AppLocalizations` (pt/en/es) consistente com o seletor de idioma do Meus Dados (3 opções) | ✅ PASS |
| `ProfileCubit` é `@lazySingleton` provido com `BlocProvider.value` no `main` — o provider **não** fecha o singleton (uso correto); telas compartilham estado (sem o problema de dado stale do Guia) | ✅ PASS |
| Tile "Notificações" continua acessível no Meus Dados (`profile_tab.dart:139`) — sem rota órfã equivalente à OBS-001 do Guia | ✅ PASS |
| `savePhotos` (fluxo novo) envia extensão `'png'` fixa — caminho do perfil social sem o bug de extensão | ✅ PASS |
| Mesmo projeto Supabase que o Guia — colunas de conta (crachá/empresa/emergência) em produção | ✅ PASS |
| Estado/CEP/CPF/telefone legados tolerados na carga da tela Dados da Conta (mesma lógica validada no Guia) | ✅ PASS |

---

## 4. Test Summary — Fase 1 (estática)

| Métrica | Valor |
|---|---|
| Verificações executadas | 24 |
| PASS | 10 |
| **FAIL (defeitos)** | **8** (V-BUG-001 a V-BUG-008) |
| Observações/decisões pendentes | 4 |
| BLOCKED (exigem dispositivo/staging) | Crop/upload real, push real, fluxo pendente de fotos pós-commit, visual em 320px |

**Distribuição por severidade:** High: 2 (V-BUG-001, 003) · Medium: 3 (V-BUG-002, 004, 005) · Low: 3 (V-BUG-006, 007, 008)

### Recomendação: **CONDITIONAL APPROVE** com correções antes do próximo release

Diferente do Guia (que tinha 3 P1 de push/navegação), o Viajante tem **1 P1 claro** (WhatsApp — V-BUG-001) e um risco de dados (V-BUG-003). Os dois têm correção pronta e validada no repo do Guia — é replicar. O V-BUG-005 deve ser resolvido **antes de commitar** o fluxo novo de fotos, e o V-BUG-004 merece prioridade de time: uma suíte sempre-vermelha esconde regressões reais.

**Ordem sugerida:** V-BUG-001 (wa.me) → V-BUG-003 (nacionalidade) → V-BUG-005 (fluxo de fotos, junto do commit em andamento) → V-BUG-002 (extensão) → V-BUG-004 (testes/CI) → V-BUG-006/007/008 + OBS-V1/V2.

---

## 5. Status das correções (atualizado em 10/07/2026)

| ID | Status | Correção aplicada |
|----|--------|-------------------|
| V-BUG-001 | ✅ **CORRIGIDO** | `profile_actions.dart`: telefone com `+` (já contém DDI) usa os dígitos como estão; sem `+` (legado) recebe fallback `55`. |
| V-BUG-002 | ✅ **CORRIGIDO** | `profile_cubit.dart`: helper `_fileExtension()` deriva a extensão de `file.name` quando `path` está vazio, com fallback `png` — aplicado em `updateProfilePhoto` e `updateCoverPhoto` (o `savePhotos` novo já enviava `'png'`). |
| V-BUG-003 | ✅ **CORRIGIDO** | `account_data_page.dart`: novo `_matchNationality` — código ISO → nome do país → gentílicos comuns; sem match, campo fica vazio forçando re-seleção (não coage mais para BR nem corrompe o dado). |
| V-BUG-004 | ✅ **CORRIGIDO** | Testes: `setUpAll` inicializa Supabase fake (sem rede, `EmptyLocalStorage`, `autoRefreshToken: false`) permitindo construir o `appRouter`; `MaterialApp.router` dos testes ganhou os delegates de l10n; teste de `/reset-password` atualizado para o comportamento atual do produto (a rota abre na etapa de **Verificação OTP**, não mais direto em "Nova senha"); `test/widget_test.dart` (template de contador, impossível de passar) removido. **Suíte: 3/3 verde.** O acoplamento `appRouter` ↔ `Supabase.instance` continua no código de produção — refatoração opcional para o time. |
| V-BUG-005 | ⏸ **NÃO ALTERADO (de propósito)** | O código do fluxo pendente de fotos está em edição não commitada por terceiros — corrigir junto desse trabalho para evitar conflito. Recomendações no corpo do bug (não limpar pendentes em falha; não emitir `ProfileState.error` global). |
| V-BUG-006 | ✅ **CORRIGIDO** | 6 chaves novas nos 3 arb (`cropperAdjustPhoto/Cover`, `cropperGestureHint`, `cropperUsePhoto`, `cropperProcessError`, `phoneSearchHint`) + `flutter gen-l10n`; `image_cropper_modal.dart` e `phone_field.dart` usando `context.l10n` (pt/en/es). |
| V-BUG-007 | ✅ **CORRIGIDO** | `login_form.dart:551` borda de foco do OTP → `AppColors.primary`; `itinerary_list.dart:249` linha tracejada → `AppColors.secondary` (teal do brandbook) com o mesmo alpha. |
| V-BUG-008 | ✅ **PARCIAL** | Removidos o bloco `if (_selectedIndex == -1)` duplicado e o `BlocBuilder<ProfileCubit>` com variável morta (`isComplete`) da `home_page` — body simplificado para ternário. Os `dev.log` verbosos foram mantidos (decisão do time — são de diagnóstico de deep link). |
| OBS-V1/V2 | ⏳ Pendente PO | `/settings` órfã e `/food-preferences` órfã — decisões de produto. |

**Estado final:** `flutter analyze` 0 erros · `flutter test` **3/3 passando** · Arquivos WIP de terceiros (`social_profile_page.dart`, `profile_header_cover.dart`) **não foram tocados** pelas correções.
