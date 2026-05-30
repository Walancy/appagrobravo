import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapta um [Stream] para [Listenable], permitindo usá-lo como
/// [refreshListenable] no GoRouter. Toda vez que o stream emite um
/// evento, os listeners registrados são notificados.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
