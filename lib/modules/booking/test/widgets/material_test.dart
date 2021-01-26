import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/material_test.dart';
import '../../test/navigate_test.dart';

void main() {
  final mockNavigate = MockNavigatorObserver();

  testWidgets('Test wrapWidget', (WidgetTester tester) async {
    // Given
    const child = Text('demo');

    // When
    await tester.pumpWidget(wrapWidget(child, mockNavigate));

    // Then
    expect(find.text('demo'), findsOneWidget);
  });

  testWidgets('Test widgetTestCanPop', (WidgetTester tester) async {
    // Given
    const child = Text('demo');

    // When
    await tester.pumpWidget(widgetTestCanPop(child, mockNavigate));

    // Then
    expect(find.text('demo'), findsOneWidget);
  });
}
