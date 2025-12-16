import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  final _connectivityController = StreamController<bool>.broadcast();

  bool _isConnected = true;

  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateConnectivity(result);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  /// Update connectivity status
  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.isNotEmpty && 
        !results.every((r) => r == ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
    }
  }

  /// Check current connectivity
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectivity(result);
    return _isConnected;
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
