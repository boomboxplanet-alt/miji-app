import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 性能監控服務
/// 
/// 提供應用性能監控和分析功能，包括：
/// - 幀率監控
/// - 內存使用監控
/// - 網絡請求監控
/// - 用戶操作追蹤
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // 監控狀態
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  
  // 性能數據
  final List<PerformanceData> _performanceData = [];
  final List<NetworkRequest> _networkRequests = [];
  final List<UserAction> _userActions = [];
  
  // 監控配置
  static const Duration _monitoringInterval = Duration(seconds: 1);
  static const int _maxDataPoints = 1000;
  
  /// 開始性能監控
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(_monitoringInterval, (_) {
      _collectPerformanceData();
    });
    
    developer.log('Performance monitoring started', name: 'PerformanceMonitor');
  }
  
  /// 停止性能監控
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    developer.log('Performance monitoring stopped', name: 'PerformanceMonitor');
  }
  
  /// 收集性能數據
  void _collectPerformanceData() {
    if (!_isMonitoring) return;
    
    final data = PerformanceData(
      timestamp: DateTime.now(),
      memoryUsage: _getMemoryUsage(),
      frameRate: _getFrameRate(),
      cpuUsage: _getCpuUsage(),
    );
    
    _performanceData.add(data);
    
    // 限制數據點數量
    if (_performanceData.length > _maxDataPoints) {
      _performanceData.removeAt(0);
    }
    
    // 檢查性能警告
    _checkPerformanceWarnings(data);
  }
  
  /// 獲取內存使用情況
  double _getMemoryUsage() {
    // 在實際應用中，這裡應該使用平台特定的API
    // 目前返回模擬數據
    return 50.0 + (DateTime.now().millisecond % 30);
  }
  
  /// 獲取幀率
  double _getFrameRate() {
    // 在實際應用中，這裡應該使用Flutter的幀率監控API
    // 目前返回模擬數據
    return 60.0 - (DateTime.now().millisecond % 10);
  }
  
  /// 獲取CPU使用率
  double _getCpuUsage() {
    // 在實際應用中，這裡應該使用平台特定的API
    // 目前返回模擬數據
    return 20.0 + (DateTime.now().millisecond % 40);
  }
  
  /// 檢查性能警告
  void _checkPerformanceWarnings(PerformanceData data) {
    if (data.frameRate < 30) {
      developer.log('Low frame rate detected: ${data.frameRate}', 
                   name: 'PerformanceMonitor', level: 900);
    }
    
    if (data.memoryUsage > 80) {
      developer.log('High memory usage detected: ${data.memoryUsage}%', 
                   name: 'PerformanceMonitor', level: 900);
    }
    
    if (data.cpuUsage > 80) {
      developer.log('High CPU usage detected: ${data.cpuUsage}%', 
                   name: 'PerformanceMonitor', level: 900);
    }
  }
  
  /// 記錄網絡請求
  void recordNetworkRequest(String url, String method, int statusCode, 
                           Duration duration, int responseSize) {
    final request = NetworkRequest(
      timestamp: DateTime.now(),
      url: url,
      method: method,
      statusCode: statusCode,
      duration: duration,
      responseSize: responseSize,
    );
    
    _networkRequests.add(request);
    
    // 限制請求記錄數量
    if (_networkRequests.length > _maxDataPoints) {
      _networkRequests.removeAt(0);
    }
    
    developer.log('Network request: $method $url - ${statusCode} (${duration.inMilliseconds}ms)', 
                 name: 'PerformanceMonitor');
  }
  
  /// 記錄用戶操作
  void recordUserAction(String action, String screen, Map<String, dynamic>? parameters) {
    final userAction = UserAction(
      timestamp: DateTime.now(),
      action: action,
      screen: screen,
      parameters: parameters,
    );
    
    _userActions.add(userAction);
    
    // 限制操作記錄數量
    if (_userActions.length > _maxDataPoints) {
      _userActions.removeAt(0);
    }
    
    developer.log('User action: $action on $screen', name: 'PerformanceMonitor');
  }
  
  /// 獲取性能報告
  PerformanceReport getPerformanceReport() {
    return PerformanceReport(
      averageFrameRate: _calculateAverageFrameRate(),
      averageMemoryUsage: _calculateAverageMemoryUsage(),
      averageCpuUsage: _calculateAverageCpuUsage(),
      networkRequestCount: _networkRequests.length,
      averageNetworkLatency: _calculateAverageNetworkLatency(),
      userActionCount: _userActions.length,
      performanceWarnings: _getPerformanceWarnings(),
    );
  }
  
  /// 計算平均幀率
  double _calculateAverageFrameRate() {
    if (_performanceData.isEmpty) return 0.0;
    
    final totalFrameRate = _performanceData
        .map((data) => data.frameRate)
        .reduce((a, b) => a + b);
    
    return totalFrameRate / _performanceData.length;
  }
  
  /// 計算平均內存使用率
  double _calculateAverageMemoryUsage() {
    if (_performanceData.isEmpty) return 0.0;
    
    final totalMemoryUsage = _performanceData
        .map((data) => data.memoryUsage)
        .reduce((a, b) => a + b);
    
    return totalMemoryUsage / _performanceData.length;
  }
  
  /// 計算平均CPU使用率
  double _calculateAverageCpuUsage() {
    if (_performanceData.isEmpty) return 0.0;
    
    final totalCpuUsage = _performanceData
        .map((data) => data.cpuUsage)
        .reduce((a, b) => a + b);
    
    return totalCpuUsage / _performanceData.length;
  }
  
  /// 計算平均網絡延遲
  Duration _calculateAverageNetworkLatency() {
    if (_networkRequests.isEmpty) return Duration.zero;
    
    final totalLatency = _networkRequests
        .map((request) => request.duration.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalLatency ~/ _networkRequests.length);
  }
  
  /// 獲取性能警告
  List<String> _getPerformanceWarnings() {
    final warnings = <String>[];
    
    final avgFrameRate = _calculateAverageFrameRate();
    if (avgFrameRate < 30) {
      warnings.add('Low average frame rate: ${avgFrameRate.toStringAsFixed(1)} FPS');
    }
    
    final avgMemoryUsage = _calculateAverageMemoryUsage();
    if (avgMemoryUsage > 80) {
      warnings.add('High average memory usage: ${avgMemoryUsage.toStringAsFixed(1)}%');
    }
    
    final avgCpuUsage = _calculateAverageCpuUsage();
    if (avgCpuUsage > 80) {
      warnings.add('High average CPU usage: ${avgCpuUsage.toStringAsFixed(1)}%');
    }
    
    return warnings;
  }
  
  /// 清除所有數據
  void clearData() {
    _performanceData.clear();
    _networkRequests.clear();
    _userActions.clear();
    
    developer.log('Performance data cleared', name: 'PerformanceMonitor');
  }
  
  /// 導出性能數據
  Map<String, dynamic> exportData() {
    return {
      'performanceData': _performanceData.map((data) => data.toJson()).toList(),
      'networkRequests': _networkRequests.map((request) => request.toJson()).toList(),
      'userActions': _userActions.map((action) => action.toJson()).toList(),
      'report': getPerformanceReport().toJson(),
    };
  }
}

/// 性能數據模型
class PerformanceData {
  final DateTime timestamp;
  final double memoryUsage;
  final double frameRate;
  final double cpuUsage;
  
  PerformanceData({
    required this.timestamp,
    required this.memoryUsage,
    required this.frameRate,
    required this.cpuUsage,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'memoryUsage': memoryUsage,
      'frameRate': frameRate,
      'cpuUsage': cpuUsage,
    };
  }
}

/// 網絡請求模型
class NetworkRequest {
  final DateTime timestamp;
  final String url;
  final String method;
  final int statusCode;
  final Duration duration;
  final int responseSize;
  
  NetworkRequest({
    required this.timestamp,
    required this.url,
    required this.method,
    required this.statusCode,
    required this.duration,
    required this.responseSize,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'url': url,
      'method': method,
      'statusCode': statusCode,
      'duration': duration.inMilliseconds,
      'responseSize': responseSize,
    };
  }
}

/// 用戶操作模型
class UserAction {
  final DateTime timestamp;
  final String action;
  final String screen;
  final Map<String, dynamic>? parameters;
  
  UserAction({
    required this.timestamp,
    required this.action,
    required this.screen,
    this.parameters,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'screen': screen,
      'parameters': parameters,
    };
  }
}

/// 性能報告模型
class PerformanceReport {
  final double averageFrameRate;
  final double averageMemoryUsage;
  final double averageCpuUsage;
  final int networkRequestCount;
  final Duration averageNetworkLatency;
  final int userActionCount;
  final List<String> performanceWarnings;
  
  PerformanceReport({
    required this.averageFrameRate,
    required this.averageMemoryUsage,
    required this.averageCpuUsage,
    required this.networkRequestCount,
    required this.averageNetworkLatency,
    required this.userActionCount,
    required this.performanceWarnings,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'averageFrameRate': averageFrameRate,
      'averageMemoryUsage': averageMemoryUsage,
      'averageCpuUsage': averageCpuUsage,
      'networkRequestCount': networkRequestCount,
      'averageNetworkLatency': averageNetworkLatency.inMilliseconds,
      'userActionCount': userActionCount,
      'performanceWarnings': performanceWarnings,
    };
  }
}

/// 性能監控Widget
class PerformanceMonitorWidget extends StatefulWidget {
  final Widget child;
  
  const PerformanceMonitorWidget({
    super.key,
    required this.child,
  });
  
  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  final PerformanceMonitor _monitor = PerformanceMonitor();
  
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _monitor.startMonitoring();
    }
  }
  
  @override
  void dispose() {
    _monitor.stopMonitoring();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 性能監控按鈕
class PerformanceMonitorButton extends StatelessWidget {
  final PerformanceMonitor _monitor = PerformanceMonitor();
  
  PerformanceMonitorButton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showPerformanceReport(context),
      backgroundColor: Colors.blue,
      child: Icon(Icons.analytics),
    );
  }
  
  void _showPerformanceReport(BuildContext context) {
    final report = _monitor.getPerformanceReport();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('性能報告'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportItem('平均幀率', '${report.averageFrameRate.toStringAsFixed(1)} FPS'),
              _buildReportItem('平均內存使用', '${report.averageMemoryUsage.toStringAsFixed(1)}%'),
              _buildReportItem('平均CPU使用', '${report.averageCpuUsage.toStringAsFixed(1)}%'),
              _buildReportItem('網絡請求數', '${report.networkRequestCount}'),
              _buildReportItem('平均網絡延遲', '${report.averageNetworkLatency.inMilliseconds}ms'),
              _buildReportItem('用戶操作數', '${report.userActionCount}'),
              if (report.performanceWarnings.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('性能警告:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...report.performanceWarnings.map((warning) => 
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $warning', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _monitor.clearData(),
            child: Text('清除數據'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('關閉'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
