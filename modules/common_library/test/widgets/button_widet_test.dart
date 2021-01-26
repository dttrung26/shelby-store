import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspireui/widgets/button_widget/button_widget.dart';

void main() {
  testWidgets('Should render Story Card successfully',
      (WidgetTester tester) async {
    // Given
    const buttonKey = ValueKey('buttonWidget');
    // When
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Builder(
          builder: (BuildContext context) {
            return ButtonWidget.primary(
              context,
              key: buttonKey,
              title: 'hihi',
            );
          },
        )),
      ),
    );

    // Then
    final btn = find.byKey(buttonKey);
    expect(btn, findsOneWidget);
    await tester.tap(btn);
  });
}
