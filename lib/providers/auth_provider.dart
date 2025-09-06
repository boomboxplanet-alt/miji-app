import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;
  
  // 獲取用戶顯示名稱
  String get userDisplayName => _authService.getUserDisplayName();
  
  // 獲取用戶頭像URL
  String? get userPhotoURL => _authService.getUserPhotoURL();
  
  // 獲取用戶ID
  String get userId => _authService.getUserId();

  AuthProvider() {
    _initializeAuth();
  }

  // 初始化認證狀態
  void _initializeAuth() {
    _user = _authService.currentUser;
  }

  // 訪客登入
  Future<bool> signInAsGuest() async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.signInAsGuest();
      
      if (user != null) {
        _user = user;
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

  // 登出
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.signOut();
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
    return _authService.getUserInfo();
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
    return await _authService.checkNetworkConnection();
  }

  // Google 登入（暫時使用訪客模式）
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();
      
      // 暫時使用訪客登入代替 Google 登入
      final user = await _authService.signInAsGuest();
      
      if (user != null) {
        _user = user;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('登入失敗: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 重新載入用戶資訊
  Future<void> reloadUser() async {
    try {
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _setError('重新載入用戶資訊失敗: ${e.toString()}');
    }
  }
}