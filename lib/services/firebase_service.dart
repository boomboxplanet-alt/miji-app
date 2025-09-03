import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();
  
  late FirebaseAuth _auth;
  late GoogleSignIn _googleSignIn;
  
  FirebaseAuth get auth => _auth;
  GoogleSignIn get googleSignIn => _googleSignIn;
  
  /// 初始化 Firebase
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
      print('Firebase 初始化成功');
    } catch (e) {
      print('Firebase 初始化失敗: $e');
      rethrow;
    }
  }
  
  /// Google 登入
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google 登入失敗: $e');
      return null;
    }
  }
  
  /// 登出
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('登出成功');
    } catch (e) {
      print('登出失敗: $e');
    }
  }
  
  /// 獲取當前用戶
  User? get currentUser => _auth.currentUser;
  
  /// 監聽認證狀態變化
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
