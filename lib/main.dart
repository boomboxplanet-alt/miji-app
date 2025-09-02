import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'providers/message_provider.dart';
import 'providers/location_provider.dart';
import 'providers/task_provider.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'utils/app_colors.dart';
import 'screens/ai_bot_control_screen.dart';
import 'screens/ai_bot_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive 本地資料庫
  await Hive.initFlutter();
  
  // 初始化 Firebase
  await AuthService.initializeFirebase();
  
  runApp(const MijiApp());
}

class MijiApp extends StatelessWidget {
  const MijiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => TaskProvider()),
      ],
      child: MaterialApp(
        title: '秘跡 Miji',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            brightness: Brightness.light,
          ),
          // 針對手機介面的優化設定
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: const CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            brightness: Brightness.dark,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MapScreen(),
        },
      ),
    );
  }
}

// 認證包裝器，直接顯示主界面
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接顯示主界面，登入功能改為按鈕形式
    return const MapScreen();
  }
}
