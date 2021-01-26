import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspireui/test/material_test.dart';
import 'package:inspireui/widgets/skeleton_widget/skeleton_widget.dart';

void main() {
  testWidgets('Skeleton should render correctly', (WidgetTester tester) async {
    // Given
    final child = Skeleton();
    final widgetPredicate = (Widget widget) =>
        widget is Container &&
        widget.decoration ==
            BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                begin: Alignment(-3, 0),
                end: Alignment(-1, 0),
                colors: [
                  Color(0x0D000000),
                  Color(0x1A000000),
                  Color(0x0D000000)
                ],
              ),
            );

    // When
    await tester.pumpWidget(makeTestableWidget(child: child));

    // Then
    expect(find.byWidgetPredicate(widgetPredicate), findsOneWidget);
  });
}
