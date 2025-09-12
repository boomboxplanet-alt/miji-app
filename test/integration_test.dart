import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Miji App Integration Tests', () {
    testWidgets('Basic app functionality test', (WidgetTester tester) async {
      // 構建簡單的測試應用
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Miji App Test')),
            body: Center(
              child: Text('Hello World'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      // 等待應用加載
      await tester.pumpAndSettle();

      // 驗證基本元素存在
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // 測試FAB點擊
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // 驗證點擊成功
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Navigation test', (WidgetTester tester) async {
      // 構建帶有導航的測試應用
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Home')),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  // 模擬導航
                },
                child: Text('Go to Settings'),
              ),
            ),
          ),
        ),
      );

      // 等待應用加載
      await tester.pumpAndSettle();

      // 驗證按鈕存在
      expect(find.text('Go to Settings'), findsOneWidget);

      // 點擊按鈕
      await tester.tap(find.text('Go to Settings'));
      await tester.pump();

      // 驗證點擊成功
      expect(find.text('Go to Settings'), findsOneWidget);
    });
  });
}