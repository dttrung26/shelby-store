import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/material_test.dart';
import '../../../widgets/booking/booking_constants.dart';
import '../../../widgets/calendar/calendar.dart';

void main() {
  testWidgets(' Render calendar', (WidgetTester tester) async {
    // Given
    final now = DateTime.now();
    final textButtonTap = find.text('${now.day + 1}');
    final builder = (context) => CalendarWidget.booking(
          context,
          key: const ValueKey(BookingConstants.keyBookingChangeDate),
          onDayPressed: (date, event) {},
          selectedDateTime: now,
        );

    // When
    await tester.pumpWidget(makeTestableWidget(builder: builder));

    // Then
    expect(find.byType(CalendarWidget), findsOneWidget);
    expect(textButtonTap, findsOneWidget);
    await tester.tap(textButtonTap);
    await tester.pump();
  });
}
