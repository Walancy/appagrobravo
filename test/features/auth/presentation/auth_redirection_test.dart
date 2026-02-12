import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrobravo/core/router/app_router.dart';
import 'package:agrobravo/features/auth/presentation/pages/login_page.dart';
import 'package:agrobravo/features/auth/presentation/widgets/auth_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthCubit = MockAuthCubit();

    when(
      () => mockAuthRepository.onAuthStateChange,
    ).thenAnswer((_) => const Stream.empty());
  });

  testWidgets(
    'Deve exibir a tela de Nova Senha ao acessar a rota /reset-password',
    (WidgetTester tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState.initial());
      when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());

      appRouter.go('/reset-password');

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: MaterialApp.router(routerConfig: appRouter),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Nova senha'), findsOneWidget);
    },
  );

  testWidgets(
    'Deve redirecionar para Nova Senha quando o AuthCubit emitir passwordRecovery',
    (WidgetTester tester) async {
      final stateController = StreamController<AuthState>.broadcast();
      when(() => mockAuthCubit.state).thenReturn(const AuthState.initial());
      when(
        () => mockAuthCubit.stream,
      ).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: MaterialApp.router(routerConfig: appRouter),
        ),
      );

      // Give it time to render initial state
      await tester.pump();

      // Simula o evento de recuperação
      stateController.add(const AuthState.passwordRecovery());

      // Wait for BlocListener to catch it and animation to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Nova senha'), findsOneWidget);

      stateController.close();
    },
  );
}
