import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/router/app_router.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/constants/supabase_constants.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/core/cubits/global_alert_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  configureDependencies();

  // Configurações de UI do Sistema (Edge-to-Edge)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(const AgroBravoApp());
}

class AgroBravoApp extends StatelessWidget {
  const AgroBravoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider(create: (context) => getIt<DocumentsCubit>()),
        BlocProvider(create: (context) => getIt<NotificationsCubit>()),
        BlocProvider(create: (context) => getIt<ItineraryCubit>()),
        BlocProvider(create: (context) => GlobalAlertCubit()),
      ],
      child: MaterialApp.router(
        title: 'AgroBravo',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
