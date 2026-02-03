import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/router/app_router.dart';
import 'package:agrobravo/core/di/injection.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrobravo/core/constants/supabase_constants.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  configureDependencies();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Active only in debug/profile mode
      builder: (context) => const AgroBravoApp(),
    ),
  );
}

class AgroBravoApp extends StatelessWidget {
  const AgroBravoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgroBravo',
      debugShowCheckedModeBanner: false,

      // DevicePreview settings
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

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
    );
  }
}
