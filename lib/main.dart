import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 暫時註釋掉 Firebase 相關導入
// import 'services/firebase_service.dart';
import 'services/location_service.dart';
import 'services/message_service.dart';
import 'services/ai_bot_service.dart';
import 'providers/app_state.dart';
import 'providers/location_provider.dart';
import 'providers/message_provider.dart';
import 'providers/task_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/map_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  await Hive.openBox('messages');
  await Hive.openBox('settings');
  
  // 暫時註釋掉 Firebase 初始化
  // await FirebaseService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<MessageService>(create: (_) => MessageService()),
        Provider<AIBotService>(create: (_) => AIBotService()),
      ],
      child: MaterialApp(
        title: '秘跡 Miji',
        debugShowCheckedModeBanner: false, // 隱藏debug標記
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          cardTheme: CardTheme(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/map': (context) => const MapScreen(),
          '/map-test': (context) => const MapTestScreen(),
        },
      ),
    );
  }
}



