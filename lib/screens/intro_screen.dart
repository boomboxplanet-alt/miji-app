import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo 或圖標
                Icon(
                  Icons.location_on,
                  size: 100,
                  color: Colors.white,
                ),
                
                SizedBox(height: 30),
                
                // 標題
                Text(
                  '秘跡 Miji',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // 副標題
                Text(
                  '限時限地的隱密訊息應用',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 50),
                
                // 開始按鈕
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return ElevatedButton(
                      onPressed: () async {
                        // 請求位置權限
                        final hasPermission = await appState.requestLocationPermission();
                        if (hasPermission) {
                          // 獲取位置
                          await appState.getCurrentLocation();
                          // 導航到地圖屏幕
                          Navigator.pushReplacementNamed(context, '/map');
                        } else {
                          // 顯示權限被拒絕的提示
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('需要位置權限才能使用應用程式'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade600,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        '開始探索',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 20),
                
                // 加載指示器
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    if (appState.isLoading) {
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

