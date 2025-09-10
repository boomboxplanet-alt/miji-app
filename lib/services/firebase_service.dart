import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();
  
  bool _isInitialized = false;
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  
  /// 初始化 Firebase
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        await Firebase.initializeApp();
        _auth = FirebaseAuth.instance;
        _googleSignIn = GoogleSignIn(
          clientId: '508695711441-r97p5ql81s4u77sirfc04dni20hu53u0.apps.googleusercontent.com',
        );
        _isInitialized = true;
        print('Firebase 初始化成功 - 秘跡miji 項目 (miji-61985)');
      }
    } catch (e) {
      print('Firebase 初始化失敗: $e');
      _isInitialized = false;
    }
  }
  
  /// Google 登入
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // 觸發 Google 登入流程
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        print('Google 登入被取消');
        return null;
      }
      
      // 獲取認證詳情
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 創建新的認證憑證
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // 使用憑證登入 Firebase
      final UserCredential userCredential = await _auth!.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user != null) {
        return {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        };
      }
      
      return null;
    } catch (e) {
      print('Google 登入失敗: $e');
      return null;
    }
  }
  
  /// 登出
  Future<void> signOut() async {
    try {
      if (_auth != null) {
        await _auth!.signOut();
      }
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
      print('登出成功');
    } catch (e) {
      print('登出失敗: $e');
    }
  }
  
  /// 獲取當前用戶
  dynamic get currentUser {
    if (!_isInitialized || _auth?.currentUser == null) {
      return null;
    }
    
    final user = _auth!.currentUser!;
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    };
  }
  
  /// 監聽認證狀態變化
  Stream<dynamic> get authStateChanges {
    if (!_isInitialized) {
      return Stream.value(null);
    }
    
    return _auth!.authStateChanges().map((User? user) {
      if (user == null) return null;
      
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      };
    });
  }
}