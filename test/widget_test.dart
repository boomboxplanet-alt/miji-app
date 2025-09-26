import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:miji_app/main.dart';
import 'package:miji_app/providers/message_provider.dart';
import 'package:miji_app/providers/location_provider.dart';
import 'package:miji_app/providers/task_provider.dart';
import 'package:miji_app/providers/auth_provider.dart';

void main() {
  group('Miji App Widget Tests', () {
    testWidgets('App should start without crashing', (WidgetTester tester) async {
      // 構建應用
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MessageProvider()),
            ChangeNotifierProvider(create: (_) => LocationProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // 等待應用加載
      await tester.pumpAndSettle();

      // 驗證應用正常啟動
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('FloatingActionButton should render correctly', (WidgetTester tester) async {
      // 構建FAB組件
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      // 等待動畫完成
      await tester.pumpAndSettle();

      // 驗證FAB存在
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('FloatingActionButton should respond to tap', (WidgetTester tester) async {
      bool tapped = false;
      
      // 構建FAB組件
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                tapped = true;
              },
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      // 等待動畫完成
      await tester.pumpAndSettle();

      // 點擊FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // 驗證點擊事件被觸發
      expect(tapped, isTrue);
    });
  });

  group('Message Provider Tests', () {
    late MessageProvider messageProvider;

    setUp(() {
      messageProvider = MessageProvider();
    });

    test('should initialize with empty messages', () {
      expect(messageProvider.messages, isEmpty);
      expect(messageProvider.isLoading, isFalse);
      expect(messageProvider.errorMessage, isNull);
    });

    test('should clear error message', () {
      // 清除錯誤訊息
      messageProvider.clearError();
      expect(messageProvider.errorMessage, isNull);
    });
  });

  group('Location Provider Tests', () {
    late LocationProvider locationProvider;

    setUp(() {
      locationProvider = LocationProvider();
    });

    test('should initialize with default values', () {
      expect(locationProvider.isLoading, isFalse);
      expect(locationProvider.errorMessage, isNull);
    });

    test('should clear error message', () {
      // 清除錯誤訊息
      locationProvider.clearError();
      expect(locationProvider.errorMessage, isNull);
    });
  });

  group('Task Provider Tests', () {
    late TaskProvider taskProvider;

    setUp(() {
      taskProvider = TaskProvider();
    });

    test('should initialize with default values', () {
      expect(taskProvider.claimableTasks, isEmpty);
      expect(taskProvider.bonusDurationMinutes, equals(0));
      expect(taskProvider.bonusRangeMeters, equals(0));
    });
  });
}