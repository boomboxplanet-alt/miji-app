import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Supabase 分析服務 - 替代 Firebase Analytics
class SupabaseAnalyticsService {
  static SupabaseAnalyticsService? _instance;
  static SupabaseAnalyticsService get instance =>
      _instance ??= SupabaseAnalyticsService._();

  SupabaseAnalyticsService._();

  final SupabaseService _supabaseService = SupabaseService.instance;

  /// 獲取 Supabase 客戶端
  SupabaseClient get client => _supabaseService.client;

  /// 記錄用戶事件
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;

      await client.from('analytics_events').insert({
        'user_id': userId,
        'event_name': eventName,
        'parameters': parameters ?? {},
        'created_at': DateTime.now().toIso8601String(),
        'session_id': _getSessionId(),
      });

      print('分析事件已記錄: $eventName');
    } catch (e) {
      print('記錄分析事件失敗: $e');
    }
  }

  /// 記錄頁面瀏覽
  Future<void> logPageView({
    required String pageName,
    Map<String, dynamic>? parameters,
  }) async {
    await logEvent(
      eventName: 'page_view',
      parameters: {
        'page_name': pageName,
        ...?parameters,
      },
    );
  }

  /// 記錄用戶登入
  Future<void> logUserLogin({
    required String loginMethod,
    bool isSuccess = true,
  }) async {
    await logEvent(
      eventName: 'user_login',
      parameters: {
        'login_method': loginMethod,
        'is_success': isSuccess,
      },
    );
  }

  /// 記錄用戶登出
  Future<void> logUserLogout() async {
    await logEvent(
      eventName: 'user_logout',
      parameters: {},
    );
  }

  /// 記錄訊息發送
  Future<void> logMessageSent({
    required String messageType,
    String? locationId,
    int? messageLength,
  }) async {
    await logEvent(
      eventName: 'message_sent',
      parameters: {
        'message_type': messageType,
        'location_id': locationId,
        'message_length': messageLength,
      },
    );
  }

  /// 記錄任務完成
  Future<void> logTaskCompleted({
    required String taskId,
    required String taskType,
    int? completionTime,
  }) async {
    await logEvent(
      eventName: 'task_completed',
      parameters: {
        'task_id': taskId,
        'task_type': taskType,
        'completion_time': completionTime,
      },
    );
  }

  /// 記錄位置更新
  Future<void> logLocationUpdate({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    await logEvent(
      eventName: 'location_update',
      parameters: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
      },
    );
  }

  /// 記錄應用程式啟動
  Future<void> logAppStart() async {
    await logEvent(
      eventName: 'app_start',
      parameters: {
        'app_version': '1.0.0',
        'platform': 'web',
      },
    );
  }

  /// 記錄應用程式錯誤
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await logEvent(
      eventName: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'stack_trace': stackTrace,
      },
    );
  }

  /// 記錄性能指標
  Future<void> logPerformance({
    required String metricName,
    required double value,
    String? unit,
  }) async {
    await logEvent(
      eventName: 'performance_metric',
      parameters: {
        'metric_name': metricName,
        'value': value,
        'unit': unit,
      },
    );
  }

  /// 記錄用戶行為
  Future<void> logUserAction({
    required String action,
    String? target,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent(
      eventName: 'user_action',
      parameters: {
        'action': action,
        'target': target,
        'metadata': metadata,
      },
    );
  }

  /// 獲取會話 ID
  String _getSessionId() {
    // 生成或獲取會話 ID
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 設置用戶屬性
  Future<void> setUserProperties({
    required Map<String, dynamic> properties,
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) return;

      await client.from('user_properties').upsert({
        'user_id': userId,
        'properties': properties,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('用戶屬性已設置');
    } catch (e) {
      print('設置用戶屬性失敗: $e');
    }
  }

  /// 獲取用戶屬性
  Future<Map<String, dynamic>?> getUserProperties() async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) return null;

      final response = await client
          .from('user_properties')
          .select('properties')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['properties'];
    } catch (e) {
      print('獲取用戶屬性失敗: $e');
      return null;
    }
  }
}
