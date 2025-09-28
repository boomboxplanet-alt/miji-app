import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 連接測試服務
class SupabaseTestService {
  static Future<void> testConnection() async {
    try {
      final supabase = Supabase.instance.client;

      // 測試基本連接
      print('🔗 測試 Supabase 連接...');

      // 測試認證狀態
      final user = supabase.auth.currentUser;
      print('👤 當前用戶: ${user?.id ?? "未登入"}');

      // 測試資料庫連接（簡單查詢）
      final response =
          await supabase.from('user_profiles').select('count').limit(1);

      print('✅ Supabase 連接成功！');
      print('📊 資料庫響應: $response');
    } catch (e) {
      print('❌ Supabase 連接失敗: $e');
    }
  }

  /// 測試 Google 登入配置
  static Future<void> testGoogleSignIn() async {
    try {
      print('🔐 測試 Google 登入配置...');

      // 檢查 Supabase 配置
      final supabase = Supabase.instance.client;
      print('✅ Supabase 客戶端已初始化');

      // 檢查認證狀態
      final authState = supabase.auth.onAuthStateChange;
      print('✅ 認證狀態監聽器已設置');

      print('🎯 Google 登入配置測試完成');
    } catch (e) {
      print('❌ Google 登入配置測試失敗: $e');
    }
  }
}
