import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 性能工具類
/// 
/// 提供各種性能優化和監控工具
class PerformanceUtils {
  /// 測量函數執行時間
  static Future<T> measureExecutionTime<T>(
    Future<T> Function() function, {
    String? name,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await function();
      stopwatch.stop();
      
      if (kDebugMode && name != null) {
        developer.log('$name executed in ${stopwatch.elapsedMilliseconds}ms', 
                     name: 'PerformanceUtils');
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      if (kDebugMode && name != null) {
        developer.log('$name failed after ${stopwatch.elapsedMilliseconds}ms: $e', 
                     name: 'PerformanceUtils');
      }
      
      rethrow;
    }
  }
  
  /// 測量同步函數執行時間
  static T measureSyncExecutionTime<T>(
    T Function() function, {
    String? name,
  }) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = function();
      stopwatch.stop();
      
      if (kDebugMode && name != null) {
        developer.log('$name executed in ${stopwatch.elapsedMilliseconds}ms', 
                     name: 'PerformanceUtils');
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      if (kDebugMode && name != null) {
        developer.log('$name failed after ${stopwatch.elapsedMilliseconds}ms: $e', 
                     name: 'PerformanceUtils');
      }
      
      rethrow;
    }
  }
  
  /// 防抖動函數
  static void debounce(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _DebounceManager.debounce(key, callback, delay);
  }
  
  /// 節流函數
  static void throttle(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    _ThrottleManager.throttle(key, callback, delay);
  }
  
  /// 延遲執行
  static void delayedExecution(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    Timer(delay, callback);
  }
  
  /// 批量處理
  static void batchProcess<T>(
    List<T> items,
    Future<void> Function(List<T>) processor, {
    int batchSize = 10,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();
      await processor(batch);
      
      if (i + batchSize < items.length) {
        await Future.delayed(delay);
      }
    }
  }
  
  /// 內存使用優化
  static void optimizeMemoryUsage() {
    // 強制垃圾回收
    if (kDebugMode) {
      developer.log('Optimizing memory usage...', name: 'PerformanceUtils');
    }
    
    // 在實際應用中，這裡可以調用平台特定的內存優化API
  }
  
  /// 檢查內存使用情況
  static double getMemoryUsage() {
    // 在實際應用中，這裡應該使用平台特定的API
    // 目前返回模擬數據
    return 50.0 + (DateTime.now().millisecond % 30);
  }
  
  /// 檢查是否為低內存設備
  static bool isLowMemoryDevice() {
    // 在實際應用中，這裡應該檢查設備的內存配置
    return false;
  }
  
  /// 優化圖片加載
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return Container(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }
  
  /// 優化列表渲染
  static Widget optimizedListView({
    required List<Widget> children,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
  
  /// 優化動畫性能
  static Widget optimizedAnimatedWidget({
    required Widget child,
    required Animation<double> animation,
    Widget Function(BuildContext, Widget?)? builder,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder ?? (context, child) => child!,
      child: child,
    );
  }
}

/// 防抖動管理器
class _DebounceManager {
  static final Map<String, Timer> _timers = {};
  
  static void debounce(
    String key,
    VoidCallback callback,
    Duration delay,
  ) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, () {
      callback();
      _timers.remove(key);
    });
  }
}

/// 節流管理器
class _ThrottleManager {
  static final Map<String, DateTime> _lastExecutions = {};
  
  static void throttle(
    String key,
    VoidCallback callback,
    Duration delay,
  ) {
    final now = DateTime.now();
    final lastExecution = _lastExecutions[key];
    
    if (lastExecution == null || 
        now.difference(lastExecution) >= delay) {
      callback();
      _lastExecutions[key] = now;
    }
  }
}

/// 性能監控Mixin
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  final Map<String, Stopwatch> _stopwatches = {};
  
  /// 開始計時
  void startTimer(String name) {
    _stopwatches[name] = Stopwatch()..start();
  }
  
  /// 結束計時
  void endTimer(String name) {
    final stopwatch = _stopwatches[name];
    if (stopwatch != null) {
      stopwatch.stop();
      
      if (kDebugMode) {
        developer.log('$name took ${stopwatch.elapsedMilliseconds}ms', 
                     name: 'PerformanceMixin');
      }
      
      _stopwatches.remove(name);
    }
  }
  
  /// 測量Widget構建時間
  Widget measureBuildTime(String name, Widget Function() builder) {
    startTimer(name);
    
    final widget = builder();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      endTimer(name);
    });
    
    return widget;
  }
}

/// 性能優化的FutureBuilder
class OptimizedFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;
  final Widget? loading;
  final Widget? error;
  
  const OptimizedFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.loading,
    this.error,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return error ?? Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        return builder(context, snapshot);
      },
    );
  }
}

/// 性能優化的StreamBuilder
class OptimizedStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;
  final Widget? loading;
  final Widget? error;
  
  const OptimizedStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.loading,
    this.error,
  });
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return error ?? Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        return builder(context, snapshot);
      },
    );
  }
}

/// 性能優化的ListView
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  
  const OptimizedListView({
    super.key,
    required this.children,
    this.controller,
    this.shrinkWrap = false,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}

/// 性能優化的GridView
class OptimizedGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ScrollController? controller;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  
  const OptimizedGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.controller,
    this.shrinkWrap = false,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}
