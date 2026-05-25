# TEST EXECUTION REPORT — AgroBravo Viajante App
**Data:** 2026-05-25 | **Método:** Static Code Analysis + Linter Output
**Arquivos analisados:** 118 arquivos Dart | **Warnings do analyzer:** 187

---

## EXECUTIVE SUMMARY

| Severidade | Qtd | Status      |
|------------|-----|-------------|
| Critical   | 3   | ✅ CORRIGIDO |
| High       | 5   | ABERTOS     |
| Medium     | 5   | ABERTOS     |
| Low        | 8   | ABERTOS     |
| **Total**  | **21** |          |

**Recomendação: CONDITIONAL APPROVE** — Nenhum dos bugs Critical bloqueia o fluxo principal do viajante (itinerário/home), mas o Critical-1 é uma vulnerabilidade de segurança ativa em produção. Exige correção antes do próximo release.

---

## BUGS CRITICAL (P1) — ✅ Corrigidos em 2026-05-25

---

### BUG-001 — Senha salva em texto puro no SharedPreferences ✅ CORRIGIDO
**Arquivo:** `lib/features/auth/presentation/cubit/auth_cubit.dart:39-40`
**Arquivo:** `lib/features/auth/presentation/widgets/login_form.dart:113-119`
**Severidade:** Critical | **Prioridade:** P1

**Passos para reproduzir:**
1. Marcar "Lembrar-me" na tela de login
2. Inspecionar SharedPreferences do device (adb/Xcode Instruments)

**Resultado obtido:**
```dart
await prefs.setString('remembered_email', email);
await prefs.setString('remembered_password', password); // ← texto puro
```
A senha ficava gravada sem nenhuma criptografia. Qualquer app com permissão de leitura do storage ou backup habilitado expõe as credenciais.

**Correção aplicada:** Removida a gravação e leitura de `remembered_password`. O "Lembrar-me" agora salva apenas o e-mail (padrão de mercado). O campo de senha permanece em branco — o usuário digita normalmente.

---

### BUG-002 — Crash ao navegar para `/document-details` e `/document-history` sem `extra` ✅ CORRIGIDO
**Arquivo:** `lib/core/router/app_router.dart:149-168`
**Severidade:** Critical | **Prioridade:** P1

**Passos para reproduzir:**
1. Navegar para `/document-details` via deep link ou por engano sem passar `extra`

**Resultado obtido:**
```dart
final extra = state.extra as Map<String, dynamic>; // ← cast sem null check
```
`state.extra` pode ser `null`. O cast lança `Null check operator used on a null value`, crashando o app sem mensagem de erro.

**Correção aplicada:** Cast seguro com `as Map<String, dynamic>?` + guard que redireciona para `/documents` quando `extra` é null.

---

### BUG-003 — `getEmergencyContacts` pode crashar quando país retorna múltiplas linhas ✅ CORRIGIDO
**Arquivo:** `lib/features/itinerary/data/repositories/itinerary_repository_impl.dart:363`
**Severidade:** Critical | **Prioridade:** P1

**Passos para reproduzir:**
1. Abrir modal de emergência em localização onde o geocoding retorna nome ambíguo (ex: "United")

**Resultado obtido:**
```dart
.or('pais.ilike.%$countryName%')
.maybeSingle(); // ← lança se mais de 1 row corresponde
```
`maybeSingle()` lança `PostgrestException` se o filtro ILIKE retornar mais de uma linha.

**Correção aplicada:** Substituído por `.limit(1)` antes de `.maybeSingle()` para garantir no máximo uma linha.

---

## BUGS HIGH (P2) — Abertos

---

### BUG-004 — Filtro de horário com endTime < startTime exclui TODOS os eventos
**Arquivo:** `lib/features/itinerary/presentation/widgets/itinerary_list.dart:78-88`
**Severidade:** High | **Prioridade:** P2

**Passos para reproduzir:**
1. Abrir filtros → definir Hora início: 22:00, Hora fim: 02:00 → Aplicar

**Resultado obtido:**
```dart
if (itemMinutes < startMinutes || itemMinutes > endMinutes) return false;
// startMinutes=1320, endMinutes=120: qualquer item é excluído
```
A lista fica completamente vazia. Não há validação de `startTime < endTime` no modal nem no filtro.

**Resultado esperado:** Adicionar validação no `ItineraryFilterModal` que impede `endTime <= startTime`.

---

### BUG-005 — Login Google/Apple trava em estado de loading se usuário cancela OAuth
**Arquivo:** `lib/features/auth/presentation/cubit/auth_cubit.dart:169-182`
**Severidade:** High | **Prioridade:** P2

**Passos para reproduzir:**
1. Tocar em "Entrar com Google"
2. No browser, fechar/voltar sem autenticar

**Resultado obtido:**
```dart
result.fold((error) => emit(AuthState.error(...)), (_) {
  // ← sucesso não emite nada; estado fica em loading para sempre
});
```
A UI exibe spinner infinito. O único escape é fechar o app.

**Resultado esperado:** Adicionar listener de `onResumed` para emitir `AuthState.unauthenticated()` se nenhuma sessão for detectada ao voltar ao app.

---

### BUG-006 — Usuário sem grupo fica em loop de erro quando offline
**Arquivo:** `lib/features/itinerary/data/repositories/itinerary_repository_impl.dart:232-271`
**Severidade:** High | **Prioridade:** P2

**Descrição:** Quando `getUserGroupId()` falha por rede, o cache só tem valor se o usuário já teve um grupo. Se nunca teve (chave removida em `_saveUserGroupIdToCache(null)`), retorna `Left(Exception)` — exibe erro em vez de "sem grupo". Impossível distinguir "sem grupo" de "sem rede".

**Resultado esperado:** Adicionar flag separada no cache (`cached_user_has_no_group: true`) para distinguir os dois casos.

---

### BUG-007 — `getLatestMissionAlert` cria notificação duplicada sob race condition
**Arquivo:** `lib/features/home/data/repositories/feed_repository_impl.dart:910-933`
**Severidade:** High | **Prioridade:** P2

**Descrição:** O padrão check-then-insert não é atômico:
```dart
final existingNotification = await ... .maybeSingle(); // check
if (existingNotification == null) {
  await ... .insert({...}); // insert — pode duplicar
}
```

**Resultado esperado:** Usar constraint `UNIQUE(user_id, grupo_id, tipo)` no banco + `upsert` com `ON CONFLICT DO NOTHING`.

---

### BUG-008 — Chamada HTTP ao Nominatim sem timeout — app pode travar
**Arquivo:** `lib/features/itinerary/data/repositories/itinerary_repository_impl.dart:334-347`
**Severidade:** High | **Prioridade:** P2

**Resultado obtido:**
```dart
final response = await http.get(url, headers: {...}); // sem timeout
```
Se o servidor Nominatim não responder, a UI de emergência trava até o timeout padrão do SO (~2 min).

**Resultado esperado:**
```dart
await http.get(url, headers: {...}).timeout(const Duration(seconds: 8));
```

---

## BUGS MEDIUM (P3) — Abertos

---

### BUG-009 — `pendingDocs` recebido em `ItineraryPage._ItineraryContent` mas nunca usado
**Arquivo:** `lib/features/itinerary/presentation/pages/itinerary_page.dart:64-161`
**Severidade:** Medium | **Prioridade:** P3

Campo `pendingDocs` declarado e recebido, mas nenhum widget no `build` o utiliza. Código morto + trabalho extra do Cubit à toa.

---

### BUG-010 — `_isSameDay` em `_ItineraryContentState` nunca é chamado
**Arquivo:** `lib/features/itinerary/presentation/pages/itinerary_tab.dart:279-281`
**Severidade:** Medium | **Prioridade:** P3

```dart
bool _isSameDay(DateTime a, DateTime b) { ... } // morto — não é referenciado
```

---

### BUG-011 — Verificação FLIGHT/RETURN no `default` do switch do DTO é unreachable
**Arquivo:** `lib/features/itinerary/data/models/itinerary_item_dto.dart:119-126`
**Severidade:** Medium | **Prioridade:** P3

`FLIGHT` e `RETURN` têm cases explícitos antes do `default`, então as verificações dentro do `default` são impossíveis de atingir. Código confuso e enganoso.

---

### BUG-012 — `DaySlider._days` não é reconstruído se `startDate`/`endDate` muda
**Arquivo:** `lib/features/itinerary/presentation/widgets/day_slider.dart:32`
**Severidade:** Medium | **Prioridade:** P3

Se o grupo mudar (pull-to-refresh retorna grupo com datas diferentes), o slider fica com os dias antigos. `didUpdateWidget` não recalcula `_days`.

---

### BUG-013 — `ItineraryContent` é classe pública mas exige BlocProvider externo
**Arquivo:** `lib/features/itinerary/presentation/pages/itinerary_tab.dart:58`
**Severidade:** Medium | **Prioridade:** P3

`class ItineraryContent` (público) pode ser instanciado de fora sem o `BlocProvider` de `ItineraryCubit`, causando `ProviderNotFoundException` em runtime. Deveria ser `_ItineraryContent` (privado).

---

## BUGS LOW (P4) — Abertos

---

### BUG-014 — `withOpacity` deprecated em 42 locais
**Arquivos:** múltiplos
Substituir por `.withValues(alpha: x)`. Sem impacto funcional.

### BUG-015 — `use_build_context_synchronously` em `document_details_page.dart:116,121`
**Arquivo:** `lib/features/documents/presentation/pages/document_details_page.dart`
BuildContext usado após `await` sem guard de `mounted`. Pode causar crash se widget for desmontado durante upload de documento.

### BUG-016 — Imports relativos em vez de `package:` em módulo itinerary
**Arquivos:** `itinerary_list.dart`, `itinerary_cards.dart`, `itinerary_filter_modal.dart`, `day_slider.dart`
Violam `always_use_package_imports`. Inconsistentes com o restante do projeto.

### BUG-017 — Variáveis desnecessárias em `createPost` (lint)
**Arquivo:** `feed_repository_impl.dart:427-429`
```dart
final likesCount = 0;    // deveria ser const
final commentsCount = 0;
final isLiked = false;
```

### BUG-018 — Comentário duplicado e contraditório em `initState`
**Arquivo:** `itinerary_tab.dart:80-81`
```dart
// Default to first day if valid range
// Default to current date if valid range  ← contradiz o anterior
```

---

## COBERTURA DO TESTE

| Módulo                                                    | Arquivos lidos | Cobertura de análise |
|-----------------------------------------------------------|----------------|----------------------|
| Itinerário (cubit, repo, entity, DTO, widgets, pages)    | 12             | 100%                 |
| Auth (cubit, repo, pages)                                  | 4              | 100%                 |
| Feed/Home (repo, cubit)                                    | 3              | 100%                 |
| Router                                                     | 1              | 100%                 |
| Documentos (pages)                                         | 3              | parcial              |
| Profile                                                    | 0              | não coberto          |
| Chat                                                       | 0              | não coberto          |
| Notificações                                               | 0              | não coberto          |

---

## HISTÓRICO DE CORREÇÕES

| Data       | Bug      | Responsável | Status      |
|------------|----------|-------------|-------------|
| 2026-05-25 | BUG-001  | Claude      | ✅ Corrigido |
| 2026-05-25 | BUG-002  | Claude      | ✅ Corrigido |
| 2026-05-25 | BUG-003  | Claude      | ✅ Corrigido |
