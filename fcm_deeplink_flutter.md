# FCM Deep Linking — Flutter + GoRouter + BLoC

Guia técnico para confrontar a implementação atual com a arquitetura correta.
Gerado a partir de análise da edge function Supabase e stack declarada: `go_router ^17.0.1` + `flutter_bloc ^9.1.1`.

---

## 1. Edge function (Supabase) — o que ela envia

A edge function envia `target_route` no campo **`data`** do payload FCM (não em `notification`).
Isso é intencional: campos em `data` chegam em **todos os estados do app** (foreground, background, terminated).

```json
{
  "message": {
    "token": "<fcm_token>",
    "notification": { "title": "...", "body": "..." },
    "data": {
      "target_route": "/chat-group/123",
      "notification_id": "uuid",
      "tipo": "...",
      "assunto": "...",
      "batepapo_id": "...",
      "grupo_id": "...",
      "post_id": "...",
      "doc_id": "...",
      "missao_id": "...",
      "solicitacao_user_id": "..."
    }
  }
}
```

**Ponto de atenção na edge function:** ela faz um re-fetch do registro no banco antes de processar,
para garantir que `target_route` esteja populado. Se a desenvolvedora estiver debugando
e vendo `target_route` vazio, o problema pode estar no timing do INSERT vs. a população
desse campo no banco — não no Flutter.

---

## 2. Os 3 estados do app e seus handlers

| Estado | Descrição | Handler correto | Quando navegar |
|---|---|---|---|
| **Foreground** | App aberto e visível | `FirebaseMessaging.onMessage` | Mostrar banner; navegar ao toque |
| **Background** | App minimizado | `FirebaseMessaging.onMessageOpenedApp` | Imediato (contexto existe) |
| **Terminated** | App fechado | `FirebaseMessaging.instance.getInitialMessage()` | Após `addPostFrameCallback` |

---

## 3. Arquitetura recomendada

### 3.1 main.dart

```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/home',
  routes: [ /* rotas do app */ ],
);

// OBRIGATÓRIO: função top-level (fora de qualquer classe)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // NÃO navegue aqui — apenas inicialize o Firebase
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  runApp(
    BlocProvider(
      create: (_) => NotificationBloc(),
      child: const AppShell(),
    ),
  );
}
```

### 3.2 NotificationBloc

```dart
// notification_event.dart
abstract class NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final String targetRoute;
  NotificationReceived(this.targetRoute);
}
```

```dart
// notification_state.dart
class NotificationState {
  final String? pendingRoute;
  const NotificationState({this.pendingRoute});

  NotificationState copyWith({String? pendingRoute}) =>
      NotificationState(pendingRoute: pendingRoute);
}
```

```dart
// notification_bloc.dart
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final List<StreamSubscription> _subscriptions = [];

  NotificationBloc() : super(const NotificationState()) {
    on<NotificationReceived>(_onNotificationReceived);
    _initListeners();
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(pendingRoute: event.targetRoute));
  }

  Future<void> _initListeners() async {
    // BACKGROUND: usuário tocou a notificação com app minimizado
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final route = message.data['target_route'];
        if (route != null && (route as String).isNotEmpty) {
          add(NotificationReceived(route));
        }
      }),
    );

    // TERMINATED: usuário tocou a notificação com app fechado
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final route = initialMessage.data['target_route'];
      if (route != null && (route as String).isNotEmpty) {
        add(NotificationReceived(route));
      }
    }
  }

  @override
  Future<void> close() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }
}
```

### 3.3 AppShell

```dart
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  StreamSubscription? _foregroundSub;

  @override
  void initState() {
    super.initState();
    _initForegroundListener();
  }

  // FOREGROUND: tratado aqui porque precisa de context para o ScaffoldMessenger
  void _initForegroundListener() {
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      final route = message.data['target_route'];
      if (route == null || (route as String).isEmpty) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? 'Nova notificação'),
          action: SnackBarAction(
            label: 'Abrir',
            onPressed: () => goRouter.go(route),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      // Só reage quando pendingRoute muda e não é nulo
      listenWhen: (previous, current) =>
          current.pendingRoute != null &&
          current.pendingRoute != previous.pendingRoute,
      listener: (context, state) {
        // addPostFrameCallback garante que o GoRouter esteja montado
        // (crítico para o estado TERMINATED)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          goRouter.go(state.pendingRoute!);
        });
      },
      child: MaterialApp.router(
        routerConfig: goRouter,
      ),
    );
  }
}
```

---

## 4. Checklist de configuração por plataforma

### Android

- `google-services.json` na pasta `android/app/`
- No `AndroidManifest.xml`, o `intent-filter` do `MainActivity` deve ter:

```xml
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

- FCM em background no Android é gerenciado pelo SO — nenhum código Dart roda.
  O handler `_firebaseBackgroundHandler` é executado em um isolate separado.

### iOS

- `GoogleService-Info.plist` na pasta `ios/Runner/`
- Solicitar permissão explicitamente (obrigatório no iOS):

```dart
await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

- No `Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

- O background handler no iOS **deve** ser uma função top-level com `@pragma('vm:entry-point')`.

---

## 5. Armadilhas comuns

### `target_route` chega vazio no Flutter

**Causa mais provável:** o campo `data` do FCM só aceita `String`. Se `target_route` for `null`
ou não estiver no payload, `message.data['target_route']` retorna `null`.

**Como debugar:**
```dart
FirebaseMessaging.onMessage.listen((message) {
  print('[FCM DATA] ${message.data}');
  print('[FCM NOTIFICATION] ${message.notification?.title}');
});
```

### Navegação no estado terminated falha silenciosamente

**Causa:** `goRouter.go()` chamado antes do widget tree estar montado.

**Solução:** sempre usar `addPostFrameCallback` para o estado terminated.
O `BlocListener` no `AppShell` já faz isso — não chamar `goRouter.go()` diretamente
em `initState` ou no construtor do Bloc.

### GoRouter `redirect` intercepta a rota da notificação

**Causa:** se o app tem um redirect de autenticação global, ele roda antes da navegação
e pode mandar o usuário para `/login` em vez da rota da notificação.

**Solução:** salvar a rota pretendida e redirecionar após o login:

```dart
redirect: (context, state) {
  final isLoggedIn = /* lógica de auth */;
  if (!isLoggedIn && state.matchedLocation != '/login') {
    return '/login?redirect=${Uri.encodeComponent(state.matchedLocation)}';
  }
  return null;
},
```

### Background handler não é top-level

**Sintoma:** crash no Android ao receber notificação com app em background.

**Solução:** a função `_firebaseBackgroundHandler` deve estar **fora de qualquer classe**,
no nível do arquivo, com a annotation `@pragma('vm:entry-point')`.

### Múltiplas instâncias do listener

**Causa:** `_initForegroundListener()` chamado mais de uma vez (ex: hot reload, rebuild do widget).

**Solução:** cancelar a subscription no `dispose()` — já previsto no `AppShell` acima.

---

## 6. Rotas geradas pela edge function

A lógica de roteamento da edge function produz as seguintes rotas — confirmar que todas
existem no GoRouter:

| Condição | Rota gerada |
|---|---|
| `kind == chatgrupo` com `batepapo_id` | `/chat-group/{batepapo_id}` |
| `kind == chatgrupo` com `grupo_id` | `/chat-group/{grupo_id}` |
| `kind == chatdireto` com `batepapo_id` | `/chat-direct/{batepapo_id}` |
| Post interaction com `post_id` | `/user-feed/{user_id}?postId={post_id}` |
| Follow/conexão com `user_id` | `/connections/{user_id}?initialIndex=1` |
| `doc_id` presente | `/documents` |
| `grupo_id` presente (fallback) | `/home?tab=0&groupId={grupo_id}` |
| Nenhuma condição | `/home` |

**Atenção:** GoRouter 17 trata query parameters automaticamente — a rota `/user-feed/:userId`
receberá `postId` via `state.uri.queryParameters['postId']`.

---

## 7. O que verificar na implementação atual

1. A leitura de `target_route` está em `message.data['target_route']` (não em `message.notification`)?
2. O handler de background é uma função top-level com `@pragma('vm:entry-point')`?
3. `getInitialMessage()` está sendo chamado e a navegação usa `addPostFrameCallback`?
4. O `goRouter` é uma instância global acessível fora do widget tree?
5. Todas as rotas listadas na seção 6 existem no GoRouter?
6. No iOS, `requestPermission()` está sendo chamado?
