import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/material_test.dart';
import '../../../widgets/choose_time/choose_time_widget.dart';

void main() {
  testWidgets('Render ChooseTimeWidget', (WidgetTester tester) async {
    // Given
    final child = ChooseTimeWidget(
      selectDate: DateTime.now().add(const Duration(days: 2)),
    );
    final textButtonTap = find.text('12:00');

    // When
    await tester.pumpWidget(
      makeTestableWidget(
          builder: (ct) => SizedBox(height: 400, width: 300, child: child)),
    );

    // Then
    expect(find.byType(ChooseTimeWidget), findsOneWidget);
    expect(textButtonTap, findsOneWidget);
    await tester.tap(textButtonTap);
    await tester.pump();
  });
}
