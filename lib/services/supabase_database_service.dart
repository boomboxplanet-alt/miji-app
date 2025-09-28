import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Supabase 資料庫服務 - 替代 Firebase Firestore
class SupabaseDatabaseService {
  static SupabaseDatabaseService? _instance;
  static SupabaseDatabaseService get instance =>
      _instance ??= SupabaseDatabaseService._();

  SupabaseDatabaseService._();

  final SupabaseService _supabaseService = SupabaseService.instance;

  /// 獲取 Supabase 客戶端
  SupabaseClient get client => _supabaseService.client;

  /// 儲存用戶資料
  Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    try {
      await client.from('user_profiles').upsert(userData);
      print('用戶資料已儲存到 Supabase');
    } catch (e) {
      print('儲存用戶資料失敗: $e');
      rethrow;
    }
  }

  /// 獲取用戶資料
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('獲取用戶資料失敗: $e');
      return null;
    }
  }

  /// 儲存訊息
  Future<void> saveMessage(Map<String, dynamic> messageData) async {
    try {
      await client.from('messages').insert(messageData);
      print('訊息已儲存到 Supabase');
    } catch (e) {
      print('儲存訊息失敗: $e');
      rethrow;
    }
  }

  /// 獲取訊息列表
  Future<List<Map<String, dynamic>>> getMessages({
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('messages')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('獲取訊息失敗: $e');
      return [];
    }
  }

  /// 儲存任務
  Future<void> saveTask(Map<String, dynamic> taskData) async {
    try {
      await client.from('tasks').insert(taskData);
      print('任務已儲存到 Supabase');
    } catch (e) {
      print('儲存任務失敗: $e');
      rethrow;
    }
  }

  /// 獲取任務列表
  Future<List<Map<String, dynamic>>> getTasks({
    int limit = 100,
  }) async {
    try {
      final response = await client
          .from('tasks')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('獲取任務失敗: $e');
      return [];
    }
  }

  /// 更新任務狀態
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await client.from('tasks').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', taskId);
      print('任務狀態已更新');
    } catch (e) {
      print('更新任務狀態失敗: $e');
      rethrow;
    }
  }

  /// 儲存位置資料
  Future<void> saveLocation(Map<String, dynamic> locationData) async {
    try {
      await client.from('locations').upsert(locationData);
      print('位置資料已儲存到 Supabase');
    } catch (e) {
      print('儲存位置資料失敗: $e');
      rethrow;
    }
  }

  /// 儲存應用程式設定
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) return;

      await client.from('app_settings').upsert({
        'user_id': userId,
        'settings': settings,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('應用程式設定已儲存到 Supabase');
    } catch (e) {
      print('儲存應用程式設定失敗: $e');
      rethrow;
    }
  }

  /// 獲取應用程式設定
  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) return null;

      final response = await client
          .from('app_settings')
          .select('settings')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['settings'];
    } catch (e) {
      print('獲取應用程式設定失敗: $e');
      return null;
    }
  }
}
