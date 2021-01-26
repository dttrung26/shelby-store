import 'package:flutter/material.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class CalendarWidget extends StatefulWidget {
  final BuildContext context;

  final DateTime selectedDateTime;

  final Function(DateTime, List<EventInterface>) onDayPressed;
  final int limitDay;
  CalendarWidget.booking(
    this.context, {
    Key key,
    @required this.selectedDateTime,
    @required this.onDayPressed,
    this.limitDay = 14,
  }) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  String header = '';

  @override
  void initState() {
    header = DateFormat('MMMM yyyy').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CalendarCarousel(
      onDayPressed: widget.onDayPressed,
      headerText: header,
      headerTitleTouchable: true,
      weekFormat: false,
      selectedDateTime: widget.selectedDateTime,
      showIconBehindDayText: true,
      daysHaveCircularBorder: false,
      customGridViewPhysics: const NeverScrollableScrollPhysics(),
      markedDateShowIcon: true,
      markedDateIconMaxShown: 2,
      onCalendarChanged: (time) {
        setState(() {
          header = DateFormat('MMMM yyyy').format(time);
        });
      },
      headerTextStyle:
          TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
      leftButtonIcon: Icon(
        Icons.arrow_back,
        color: Theme.of(context).iconTheme.color,
      ),
      rightButtonIcon: Icon(
        Icons.arrow_forward,
        color: Theme.of(context).iconTheme.color,
      ),
      minSelectedDate: DateTime.now().subtract(const Duration(days: 1)),
      maxSelectedDate: DateTime.now().add(Duration(days: widget.limitDay)),
      todayButtonColor: Colors.transparent,
      todayBorderColor: Colors.transparent,
      daysTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      weekdayTextStyle:
          TextStyle(color: Theme.of(context).buttonTheme.colorScheme.onPrimary),
      todayTextStyle: TextStyle(
        color: Theme.of(context).primaryColor,
      ),
      selectedDayTextStyle: const TextStyle(color: Colors.white),
      selectedDayBorderColor: Colors.transparent,
      selectedDayButtonColor: Theme.of(context).primaryColor,
      weekendTextStyle:
          TextStyle(color: Theme.of(context).buttonTheme.colorScheme.onPrimary),
      markedDateMoreShowTotal: true,
      inactiveDaysTextStyle: TextStyle(
        color: Theme.of(context).unselectedWidgetColor.withOpacity(0.5),
      ),
      inactiveWeekendTextStyle: TextStyle(
        color: Theme.of(context).unselectedWidgetColor.withOpacity(0.5),
      ),
    );
  }
}
