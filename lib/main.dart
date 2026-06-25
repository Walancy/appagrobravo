import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/router/app_router.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart';
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart';
import 'package:agrobravo/core/cubits/global_alert_cubit.dart';
import 'package:agrobravo/core/cubits/theme_cubit.dart';
import 'package:agrobravo/core/cubits/locale_cubit.dart';
import 'package:agrobravo/l10n/generated/app_localizations.dart';
import 'package:agrobravo/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:agrobravo/core/services/notification_navigation_service.dart';

/// Handler de mensagens em background (precisa ser top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) log('FCM background message: ${message.messageId}');
}

/// Solicita permissão de push e salva o token FCM em public.users.
Future<void> setupFCM() async {
  final messaging = FirebaseMessaging.instance;

  // Registra handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Solicita permissão ao usuário (iOS mostra o diálogo nativo)
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (kDebugMode) log('FCM permission: ${settings.authorizationStatus}');

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    await _getFcmTokenAndSave(messaging);
    // Atualiza token quando ele rotacionar
    messaging.onTokenRefresh.listen(_saveFcmToken);
  }
}

/// No iOS, o APNS token é registrado de forma assíncrona pelo sistema.
/// Aguarda até 10 tentativas com delay crescente antes de chamar getToken().
Future<void> _getFcmTokenAndSave(FirebaseMessaging messaging) async {
  // Em Android não há APNS token — pula a espera
  if (!defaultTargetPlatform.name.contains('iOS') &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    try {
      final token = await messaging.getToken();
      if (token != null) _saveFcmToken(token);
    } catch (e) {
      if (kDebugMode) log('Erro ao obter FCM token (Android): $e');
    }
    return;
  }

  // iOS: aguarda APNS token com retry exponencial
  for (int attempt = 1; attempt <= 10; attempt++) {
    try {
      final apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        // APNS token disponível — agora podemos obter o FCM token
        final token = await messaging.getToken();
        if (token != null) _saveFcmToken(token);
        return;
      }
    } catch (_) {}

    // Aguarda antes da próxima tentativa (500ms, 1s, 1.5s... até 5s)
    await Future.delayed(Duration(milliseconds: 500 * attempt));
  }

  if (kDebugMode) log('FCM: APNS token não disponível após 10 tentativas. Push pode não funcionar.');
}

void _saveFcmToken(String token) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;
  Supabase.instance.client
      .from('users')
      .update({'fcm_token': token})
      .eq('id', userId)
      .then((_) => { if (kDebugMode) log('FCM token salvo') })
      .catchError((e) => { if (kDebugMode) log('Erro ao salvar FCM token: $e') });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[NOTIF] main() started');

  await dotenv.load(fileName: ".env");
  await Future.wait([
    initializeDateFormatting('pt_BR', null),
    initializeDateFormatting('en_US', null),
    initializeDateFormatting('es_ES', null),
  ]);

  final isFirebaseSupported = kIsWeb || 
      defaultTargetPlatform == TargetPlatform.android || 
      defaultTargetPlatform == TargetPlatform.iOS || 
      defaultTargetPlatform == TargetPlatform.macOS;

  // Inicializa Firebase (necessário para push notifications)
  if (isFirebaseSupported) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      if (kDebugMode) log('Erro ao inicializar Firebase: $e');
    }
  }

  await Supabase.initialize(
    url: dotenv.env['NEXT_PUBLIC_SUPABASE_URL']!,
    anonKey: dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY']!,
  );

  configureDependencies();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Configure audio playback session globally so audio plays on iOS
  // even when the device is in silent/ring mode, and gets proper focus on Android.
  try {
    await AudioPlayer.global.setAudioContext(AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.defaultToSpeaker},
      ),
      android: AudioContextAndroid(
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
        isSpeakerphoneOn: true,
      ),
    ));
  } catch (e) {
    if (kDebugMode) log('Audio context setup failed: $e');
  }

  if (isFirebaseSupported) {
    try {
      setupFCM();
      NotificationNavigationService.initialize();

      // Capture the cold-start notification synchronously before runApp() so
      // the Android launch Intent is guaranteed to be available.
      // getInitialMessage() is a fast platform-channel call at this point.
      final coldMsg = await FirebaseMessaging.instance.getInitialMessage();
      if (coldMsg != null) {
        if (kDebugMode) log('[push] Cold-start message in main: ${coldMsg.data}');
        NotificationNavigationService.setColdStartMessage(coldMsg);
      }
    } catch (e) {
      if (kDebugMode) log('Erro ao configurar FCM: $e');
    }
  }

  // Variável para ativar/desativar a moldura de dispositivo para testes.
  // Quando for para produção (release mode), a moldura será desativada automaticamente.
  const bool showDeviceFrame = false;

  runApp(
    DevicePreview(
      enabled: showDeviceFrame && !kReleaseMode,
      builder: (context) => const AgroBravoApp(),
    ),
  );
}

class AgroBravoApp extends StatefulWidget {
  const AgroBravoApp({super.key});

  @override
  State<AgroBravoApp> createState() => _AgroBravoAppState();
}

class _AgroBravoAppState extends State<AgroBravoApp> {
  @override
  void initState() {
    super.initState();
    // Wait two frames: first renders the initial route (possibly login/home),
    // second ensures GoRouter has finished any auth-triggered redirect before
    // we attempt deep-link navigation from a cold-start push notification.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationNavigationService.markRouterReady();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ThemeCubit>()),
        BlocProvider(create: (context) => LocaleCubit()),
        BlocProvider.value(value: getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider.value(value: getIt<ProfileCubit>()..loadProfile()),
        BlocProvider.value(value: getIt<DocumentsCubit>()),
        BlocProvider.value(value: getIt<NotificationsCubit>()),
        BlocProvider.value(value: getIt<ItineraryCubit>()),
        BlocProvider.value(value: getIt<ChatCubit>()),
        BlocProvider(create: (context) => GlobalAlertCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'AgroBravo',
                debugShowCheckedModeBanner: false,
                locale: DevicePreview.locale(context) ?? locale,
                builder: DevicePreview.appBuilder,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                themeMode: themeMode,
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                routerConfig: appRouter,
              );
            },
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base,
      textTheme: GoogleFonts.barlowTextTheme(),
      dividerTheme: const DividerThemeData(color: AppColors.backgroundLight, space: 1),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.07)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      listTileTheme: const ListTileThemeData(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.grey.shade300;
        }),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.backgroundLightDark,
      onSurface: AppColors.textPrimaryDark,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: base,
      textTheme: GoogleFonts.barlowTextTheme(ThemeData.dark().textTheme),
      dividerTheme: const DividerThemeData(color: Color(0xFF2A2A2A), space: 1),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.backgroundLightDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLightDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
      ),
      listTileTheme: const ListTileThemeData(
        minLeadingWidth: 0,
        horizontalTitleGap: 12,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return const Color(0xFF3A3A3A);
        }),
      ),
    );
  }
}
