import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  late StreamSubscription _subscription;
  Timer? _pingTimer;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  ConnectivityService() {
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnection);
    _startPingTimer();
  }

  void _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    await _updateConnection(results);
  }

  Future<void> _updateConnection(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      _setOnlineStatus(false);
    } else {
      final hasInternet = await _hasInternetConnection();
      _setOnlineStatus(hasInternet);
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _setOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    }
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!_isOnline) {
        final hasInternet = await _hasInternetConnection();
        if (hasInternet) {
          _setOnlineStatus(true);
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _pingTimer?.cancel();
    super.dispose();
  }
}