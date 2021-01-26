import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test/material_test.dart';
import '../../../widgets/booking/booking_constants.dart';
import '../../../widgets/booking/booking_widget.dart';
import '../../../widgets/calendar/calendar.dart';

void main() {
  testWidgets('Render BookingWidget', (WidgetTester tester) async {
    // Given
    const keyChangeDate = ValueKey(BookingConstants.keyBookingChangeDate);
    const keyBookingNow = ValueKey(BookingConstants.keyBookingNow);
    final child = BookingWidget(
      controller: null,
      idProduct: '',
    );
    final now = DateTime.now();
    final textButtonTap = find.text('${now.day + 1}');

    // When
    await tester.pumpWidget(
      makeTestableWidget(
        builder: (context) => Container(
          height: BookingConstants.maxHeightBookingWidget,
          width: 300,
          child: child,
        ),
      ),
    );

    // Then
    expect(find.byType(CalendarWidget), findsOneWidget);
    expect(find.byKey(keyChangeDate), findsOneWidget);
    expect(find.byKey(keyBookingNow), findsOneWidget);
    expect(textButtonTap, findsOneWidget);
    await tester.pump();
    await tester.tap(textButtonTap);
    await tester.pump();
    await tester.tap(find.byKey(keyBookingNow));
  });
}
