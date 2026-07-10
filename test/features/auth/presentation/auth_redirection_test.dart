import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrobravo/core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_state.dart';
import 'package:agrobravo/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthCubit mockAuthCubit;

  setUpAll(() async {
    // O appRouter referencia Supabase.instance na inicialização top-level;
    // inicializa uma instância fake (sem rede) para os testes poderem
    // construir o router.
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        localStorage: EmptyLocalStorage(),
      ),
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthCubit = MockAuthCubit();

    when(
      () => mockAuthRepository.onAuthStateChange,
    ).thenAnswer((_) => const Stream.empty());
  });

  testWidgets(
    'Deve exibir a tela de Verificação (OTP) ao acessar a rota /reset-password',
    (WidgetTester tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.initial());
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      appRouter.go('/reset-password');

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: MaterialApp.router(
            routerConfig: appRouter,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      // O fluxo de redefinição mudou: /reset-password abre primeiro a etapa
      // de verificação do código OTP (AuthMode.otpVerification).
      expect(find.text('Verificação'), findsOneWidget);
    },
  );

  testWidgets(
    'Deve redirecionar para Nova Senha quando o AuthCubit emitir otpVerified',
    (WidgetTester tester) async {
      final stateController = StreamController<AuthState>.broadcast();
      when(() => mockAuthCubit.state).thenReturn(const AuthState.initial());
      when(
        () => mockAuthCubit.stream,
      ).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: MaterialApp.router(
            routerConfig: appRouter,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
          ),
        ),
      );

      // Give it time to render initial state
      await tester.pump();

      // Simula o evento de OTP verificado com sucesso
      stateController.add(const AuthState.otpVerified());

      // Wait for BlocListener to catch it and animation to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Nova senha'), findsOneWidget);

      stateController.close();
    },
  );
}
