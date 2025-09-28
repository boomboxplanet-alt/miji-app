import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/message_service.dart';
import 'services/ai_bot_service.dart';
import 'services/performance_monitor.dart';
import 'providers/app_state.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/message_provider.dart';
import 'providers/task_provider.dart';
import 'screens/map_screen.dart';
import 'screens/performance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Supabase 認證服務
  await AuthService.initializeSupabase();

  // 初始化 Hive
  await Hive.initFlutter();
  await Hive.openBox('messages');
  await Hive.openBox('settings');

  // 初始化性能監控
  final performanceMonitor = PerformanceMonitor();
  performanceMonitor.startMonitoring();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<MessageService>(create: (_) => MessageService()),
        Provider<AIBotService>(create: (_) => AIBotService()),
      ],
      child: MaterialApp(
        title: '秘跡 Miji',
        debugShowCheckedModeBanner: false, // 隱藏調試橫幅
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          cardTheme: CardThemeData(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: MapScreen(),
        routes: {
          '/map': (context) => MapScreen(),
          '/performance': (context) => PerformanceScreen(),
        },
      ),
    );
  }
}
