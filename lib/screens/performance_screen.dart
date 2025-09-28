import 'package:flutter/material.dart';
import '../services/performance_monitor.dart';

/// 性能監控頁面
///
/// 顯示應用性能數據和監控信息
class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final PerformanceMonitor _monitor = PerformanceMonitor();
  PerformanceReport? _report;
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _updateReport();
  }

  void _updateReport() {
    setState(() {
      _report = _monitor.getPerformanceReport();
    });
  }

  void _toggleMonitoring() {
    setState(() {
      _isMonitoring = !_isMonitoring;
      if (_isMonitoring) {
        _monitor.startMonitoring();
      } else {
        _monitor.stopMonitoring();
      }
    });
  }

  void _clearData() {
    _monitor.clearData();
    _updateReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('性能監控'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleMonitoring,
            tooltip: _isMonitoring ? '停止監控' : '開始監控',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _updateReport,
            tooltip: '刷新數據',
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearData,
            tooltip: '清除數據',
          ),
        ],
      ),
      body: _report == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonitoringStatus(),
                  SizedBox(height: 16),
                  _buildPerformanceMetrics(),
                  SizedBox(height: 16),
                  _buildNetworkMetrics(),
                  SizedBox(height: 16),
                  _buildUserActionMetrics(),
                  SizedBox(height: 16),
                  _buildPerformanceWarnings(),
                  SizedBox(height: 16),
                  _buildActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildMonitoringStatus() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isMonitoring
                  ? Icons.monitor_heart
                  : Icons.monitor_heart_outlined,
              color: _isMonitoring ? Colors.green : Colors.grey,
              size: 32,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '監控狀態',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _isMonitoring ? '正在監控' : '已停止',
                    style: TextStyle(
                      color: _isMonitoring ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isMonitoring,
              onChanged: (_) => _toggleMonitoring(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '性能指標',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            _buildMetricItem(
              '平均幀率',
              '${_report!.averageFrameRate.toStringAsFixed(1)} FPS',
              _getFrameRateColor(_report!.averageFrameRate),
            ),
            _buildMetricItem(
              '平均內存使用',
              '${_report!.averageMemoryUsage.toStringAsFixed(1)}%',
              _getMemoryUsageColor(_report!.averageMemoryUsage),
            ),
            _buildMetricItem(
              '平均CPU使用',
              '${_report!.averageCpuUsage.toStringAsFixed(1)}%',
              _getCpuUsageColor(_report!.averageCpuUsage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkMetrics() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '網絡指標',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            _buildMetricItem(
              '網絡請求數',
              '${_report!.networkRequestCount}',
              Colors.blue,
            ),
            _buildMetricItem(
              '平均網絡延遲',
              '${_report!.averageNetworkLatency.inMilliseconds}ms',
              _getLatencyColor(_report!.averageNetworkLatency.inMilliseconds),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActionMetrics() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用戶操作',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            _buildMetricItem(
              '操作次數',
              '${_report!.userActionCount}',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceWarnings() {
    if (_report!.performanceWarnings.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 16),
              Text(
                '沒有性能警告',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '性能警告',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._report!.performanceWarnings.map(
              (warning) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '操作',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearData,
                    icon: Icon(Icons.clear),
                    label: Text('清除數據'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportData,
                    icon: Icon(Icons.download),
                    label: Text('導出數據'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFrameRateColor(double frameRate) {
    if (frameRate >= 50) return Colors.green;
    if (frameRate >= 30) return Colors.orange;
    return Colors.red;
  }

  Color _getMemoryUsageColor(double memoryUsage) {
    if (memoryUsage <= 50) return Colors.green;
    if (memoryUsage <= 80) return Colors.orange;
    return Colors.red;
  }

  Color _getCpuUsageColor(double cpuUsage) {
    if (cpuUsage <= 50) return Colors.green;
    if (cpuUsage <= 80) return Colors.orange;
    return Colors.red;
  }

  Color _getLatencyColor(int latency) {
    if (latency <= 100) return Colors.green;
    if (latency <= 500) return Colors.orange;
    return Colors.red;
  }

  void _exportData() {
    _monitor.exportData();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('導出數據'),
        content: Text('性能數據已準備好導出'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('關閉'),
          ),
        ],
      ),
    );
  }
}
