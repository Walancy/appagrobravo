import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/router/app_router.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/core/cubits/global_alert_cubit.dart';
import 'package:agrobravo/core/cubits/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await initializeDateFormatting('pt_BR', null);

  await Supabase.initialize(
    url: dotenv.env['NEXT_PUBLIC_SUPABASE_URL']!,
    anonKey: dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY']!,
  );

  configureDependencies();

  // Configurações de UI do Sistema (Edge-to-Edge)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const AgroBravoApp());
}

class AgroBravoApp extends StatelessWidget {
  const AgroBravoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ThemeCubit>()),
        BlocProvider(
          create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(create: (context) => getIt<DocumentsCubit>()),
        BlocProvider(create: (context) => getIt<NotificationsCubit>()),
        BlocProvider(create: (context) => getIt<ItineraryCubit>()),
        BlocProvider(create: (context) => GlobalAlertCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'AgroBravo',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.surface,
                onSurface: AppColors.textPrimary,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              dividerTheme: const DividerThemeData(
                color: AppColors.backgroundLight,
              ),
            ),
            darkTheme: ThemeData(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.backgroundDark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.surfaceDark,
                onSurface: AppColors.textPrimaryDark,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              dividerTheme: const DividerThemeData(
                color: AppColors.backgroundLightDark,
              ),
            ),
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
