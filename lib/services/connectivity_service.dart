import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService extends ChangeNotifier {
  bool _isConnected = true;
  ConnectivityResult _connectionStatus = ConnectivityResult.wifi;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool get isConnected => _isConnected;
  bool get isOffline => !_isConnected;
  bool get isWifi => _connectionStatus == ConnectivityResult.wifi;
  bool get isMobile => _connectionStatus == ConnectivityResult.mobile;
  bool get isEthernet => _connectionStatus == ConnectivityResult.ethernet;
  bool get isBluetooth => _connectionStatus == ConnectivityResult.bluetooth;
  bool get isVPN => _connectionStatus == ConnectivityResult.vpn;
  ConnectivityResult get connectionStatus => _connectionStatus;

  ConnectivityService() {
    _initConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Could not check connectivity status: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        debugPrint('Connectivity stream error: $error');
      },
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    final oldStatus = _connectionStatus;
    
    // Get the first result or none if empty
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    
    _connectionStatus = result;
    _isConnected = result != ConnectivityResult.none;
    
    if (wasConnected != _isConnected || oldStatus != _connectionStatus) {
      debugPrint('Connectivity changed: ${getConnectionTypeString()}');
      notifyListeners();
    }
  }

  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty && result.first != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      return false;
    }
  }

  String getConnectionTypeString() {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  bool get hasStableConnection => isWifi || isEthernet;
  bool get isLimitedConnection => isMobile || isBluetooth;
  bool get canStreamHD => isWifi || isEthernet;
  bool get shouldUseOfflineMode => isOffline;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}