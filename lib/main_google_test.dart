import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(GoogleTestApp());
}

class GoogleTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google登入測試',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GoogleTestPage(),
    );
  }
}

class GoogleTestPage extends StatefulWidget {
  @override
  _GoogleTestPageState createState() => _GoogleTestPageState();
}

class _GoogleTestPageState extends State<GoogleTestPage> {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '508695711441-r97p5ql81s4u77sirfc04dni20hu53u0.apps.googleusercontent.com',
  );
  
  GoogleSignInAccount? _currentUser;
  String _status = '準備就緒';
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _addMessage('應用程式已啟動');
    _addMessage('Google Sign-In 已初始化');
  }

  void _addMessage(String message) {
    setState(() {
      _messages.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _status = '正在登入...';
    });
    _addMessage('開始Google登入流程');

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account != null) {
        setState(() {
          _currentUser = account;
          _status = '登入成功！';
        });
        _addMessage('✅ 登入成功: ${account.displayName}');
        _addMessage('📧 電子郵件: ${account.email}');
        _addMessage('🆔 用戶ID: ${account.id}');
      } else {
        setState(() {
          _status = '登入已取消';
        });
        _addMessage('❌ 用戶取消了登入');
      }
    } catch (error) {
      setState(() {
        _status = '登入失敗';
      });
      _addMessage('❌ 登入錯誤: $error');
    }
  }

  Future<void> _handleGoogleSignOut() async {
    setState(() {
      _status = '正在登出...';
    });
    _addMessage('開始Google登出流程');

    try {
      await _googleSignIn.signOut();
      setState(() {
        _currentUser = null;
        _status = '已登出';
      });
      _addMessage('✅ 登出成功');
    } catch (error) {
      setState(() {
        _status = '登出失敗';
      });
      _addMessage('❌ 登出錯誤: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google登入測試'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 狀態顯示
              Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        _currentUser != null ? Icons.account_circle : Icons.person_outline,
                        color: _currentUser != null ? Colors.green : Colors.grey,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Google登入狀態',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _status,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_currentUser != null) ...[
                        SizedBox(height: 16),
                        Text(
                          '歡迎，${_currentUser!.displayName}！',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          _currentUser!.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // 登入/登出按鈕
              if (_currentUser == null)
                ElevatedButton.icon(
                  onPressed: _handleGoogleSignIn,
                  icon: Icon(Icons.login),
                  label: Text('使用 Google 登入'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _handleGoogleSignOut,
                  icon: Icon(Icons.logout),
                  label: Text('登出'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              
              SizedBox(height: 20),
              
              // 訊息列表
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '操作記錄',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: _messages.isEmpty
                              ? Center(
                                  child: Text(
                                    '暫無記錄',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        _messages[index],
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
