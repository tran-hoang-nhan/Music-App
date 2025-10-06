import 'dart:async';
import 'package:flutter/foundation.dart';

class PerformanceUtils {
  static Timer? _debounceTimer;
  
  /// Debounce function calls to prevent excessive API requests
  static void debounce(Duration delay, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
  
  /// Throttle function calls to limit frequency
  static DateTime? _lastThrottleTime;
  static bool throttle(Duration interval) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      return true;
    }
    return false;
  }
  
  /// Batch process items to avoid blocking UI
  static Future<List<T>> batchProcess<T, R>(
    List<T> items,
    Future<R?> Function(T) processor, {
    int batchSize = 3,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final results = <R>[];
    
    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map((item) => processor(item).catchError((_) => null)),
      );
      
      results.addAll(batchResults.where((r) => r != null).cast<R>());
      
      if (i + batchSize < items.length) {
        await Future.delayed(delay);
      }
    }
    
    return results.cast<T>();
  }
}