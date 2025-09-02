import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:miji_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MijiApp());

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
