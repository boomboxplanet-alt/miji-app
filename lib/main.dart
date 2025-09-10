import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';  // 暫時註釋掉
import 'package:hive_flutter/hive_flutter.dart';

import 'services/simple_firebase_service.dart';
import 'services/location_service.dart';
import 'services/message_service.dart';
import 'services/ai_bot_service.dart';
import 'providers/app_state.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/message_provider.dart';
import 'providers/task_provider.dart';
import 'screens/intro_screen.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  await Hive.openBox('messages');
  await Hive.openBox('settings');
  
  // 初始化簡化 Firebase 服務
  await SimpleFirebaseService.instance.initialize();
  
  // 等待一下確保服務完全初始化
  // await Future.delayed(Duration(milliseconds: 500));
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        home: MapScreen(),
        routes: {
          '/map': (context) => MapScreen(),
        },
      ),
    );
  }
}



