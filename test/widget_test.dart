import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elder_buddy/app.dart';

void main() {
  testWidgets('ElderBuddyApp builds without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EasyCallApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
