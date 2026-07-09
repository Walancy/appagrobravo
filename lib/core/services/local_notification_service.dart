import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Serviço responsável por inicializar e exibir notificações locais.
/// Utilizado principalmente no Android para forçar a exibição do banner
/// de notificação quando o aplicativo estiver em primeiro plano (foreground).
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'Notificações Importantes', // title
    description: 'Este canal é usado para notificações importantes do app.', // description
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Inicializa o serviço e cria o canal de notificações no Android.
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          dev.log(
            '[NOTIF] Local notification clicked: ${response.payload}',
            name: 'local_notification_service',
          );
        },
      );

      // Cria o canal de notificações de alta importância no Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
        dev.log('[NOTIF] Android Notification Channel registered', name: 'local_notification_service');
      }
    } catch (e) {
      dev.log('[NOTIF] Failed to initialize local notifications: $e', name: 'local_notification_service');
    }
  }

  /// Exibe uma notificação local instantaneamente.
  static Future<void> showNotification(String title, String body, {String? payload}) async {
    try {
      await _notificationsPlugin.show(
        id: title.hashCode,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      dev.log('[NOTIF] Failed to show local notification: $e', name: 'local_notification_service');
    }
  }
}
