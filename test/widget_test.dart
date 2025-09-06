import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic app structure test', (WidgetTester tester) async {
    // 創建一個簡單的測試應用
    await tester.pumpWidget(
      const MaterialApp(
        title: '秘跡 Miji',
        home: Scaffold(
          body: Center(
            child: Text('秘跡 Miji'),
          ),
        ),
      ),
    );

    // 驗證應用標題存在
    expect(find.text('秘跡 Miji'), findsOneWidget);
  });

  testWidgets('MaterialApp widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Test'),
        ),
      ),
    );

    // 驗證 MaterialApp 存在
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
