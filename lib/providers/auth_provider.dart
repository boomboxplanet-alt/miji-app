import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  dynamic _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  dynamic get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  // 獲取用戶顯示名稱
  String get userDisplayName => _user?['displayName'] ?? '訪客';

  // 獲取用戶頭像URL
  String? get userPhotoURL => _user?['photoURL'];

  // 獲取用戶ID
  String get userId => _user?['uid'] ?? '';

  AuthProvider() {
    _initializeAuth();
  }

  // 初始化認證狀態
  void _initializeAuth() {
    try {
      _user = _supabaseService.getUserInfo();
      // 監聽認證狀態變化
      _supabaseService.authStateChanges.listen((AuthState state) {
        _user = _supabaseService.getUserInfo();
        notifyListeners();
      });
    } catch (e) {
      print('AuthProvider 初始化失敗: $e');
      _user = null;
    }
  }

  // 訪客登入
  Future<bool> signInAsGuest() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabaseService.signInAnonymously();

      if (response?.user != null) {
        _user = _supabaseService.getUserInfo();
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError('訪客登入失敗: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google 登入
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabaseService.signInWithGoogle();

      if (response?.user != null) {
        _user = _supabaseService.getUserInfo();
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Google 登入失敗: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _supabaseService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('登出失敗: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 獲取用戶資訊
  Map<String, dynamic>? getUserInfo() {
    if (_user == null) return null;

    return {
      'uid': _user['uid'],
      'email': _user['email'],
      'displayName': _user['displayName'],
      'photoURL': _user['photoURL'],
    };
  }

  // 設置載入狀態
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 設置錯誤訊息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // 清除錯誤訊息
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 清除錯誤（供UI調用）
  void clearError() {
    _clearError();
  }

  // 檢查網路連接
  Future<bool> checkConnection() async {
    // 簡單的網路檢查
    try {
      await Future.delayed(Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }

  // 重新載入用戶資訊
  Future<void> reloadUser() async {
    try {
      await _supabaseService.reloadUser();
      _user = _supabaseService.getUserInfo();
      notifyListeners();
    } catch (e) {
      _setError('重新載入用戶資訊失敗: ${e.toString()}');
    }
  }
}
