import 'package:flutter/material.dart';

import 'choose_time_constants.dart';

class ChooseTimeWidget extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final DateTime selectDate;
  final int paddingTime;
  final int initValue;
  final Function onChooseTime;

  ChooseTimeWidget({
    Key key,
    this.initValue = 0,
    this.startTime,
    this.endTime,
    this.selectDate,
    this.paddingTime = 60,
    this.onChooseTime,
  })  : assert(
          paddingTime != null && paddingTime >= 1 && paddingTime <= 60,
          ' 1 <= paddingTime <= 60',
        ),
        super(key: key);

  @override
  _ChooseTimeWidgetState createState() => _ChooseTimeWidgetState();
}

class _ChooseTimeWidgetState extends State<ChooseTimeWidget> {
  DateTime get _startTime => widget.startTime;
  DateTime get _endTime => widget.endTime;
  final listTitle = <Widget>[];
  int _timeSelect = 0;

  List<Widget> _renderTime() {
    var timeNow = DateTime.now();

    if (_startTime != null) {
      timeNow = _startTime;
    }

    final listWidget = <Widget>[];
    var currentHour = 0;
    currentHour = timeNow.hour;

    for (final item in ChooseTimeConstants.defineLimitTime) {
      if (_endTime != null &&
          (currentHour > _endTime.hour ||
              (widget.paddingTime >= _endTime.minute &&
                  currentHour == _endTime.hour))) {
        break;
      }

      if (currentHour < item['timeStart']) {
        currentHour = item['timeStart'];
      }
      var endHour = _endTime?.hour ?? item['timeEnd'];
      if (endHour > item['timeEnd']) {
        endHour = item['timeEnd'];
      }

      listWidget.add(Expanded(
        child: _renderChooseTimeWidget(
          timeStart: currentHour,
          timeEnd: endHour,
        ),
      ));
    }

    return listWidget;
  }

  @override
  void didUpdateWidget(ChooseTimeWidget oldWidget) {
    if (oldWidget.selectDate != widget.selectDate ||
        widget.initValue != oldWidget.initValue) {
      _timeSelect = widget.initValue;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _timeSelect = widget.initValue;
    if (_endTime != null && _endTime is DateTime) {
      ChooseTimeConstants.defineLimitTime.last['timeEnd'] = _endTime.hour;
    }
    super.initState();
  }

  Widget _renderListTitle() {
    final List lstTitle = <Widget>[];
    ChooseTimeConstants.defineLimitTime.forEach((item) {
      lstTitle.add(Expanded(
          child: Text(
        item['title'],
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      )));
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: lstTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        children: [
          _renderListTitle(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _renderTime(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtonTime(int hour) {
    return FlatButton(
      color: _timeSelect == hour
          ? Theme.of(context).primaryColor
          : Colors.transparent,
      textColor: _timeSelect == hour
          ? Colors.white
          : Theme.of(context).buttonTheme.colorScheme.onPrimary,
      onPressed: () {
        widget.onChooseTime?.call(hour);
        setState(() {
          _timeSelect = hour;
        });
      },
      child: Text('$hour:00'),
    );
  }

  Widget _renderChooseTimeWidget({int timeStart, int timeEnd}) {
    final _listTimeWidget = <Widget>[];
    for (var _indS = timeStart; _indS <= timeEnd; _indS++) {
      _listTimeWidget.add(_buildButtonTime(_indS));
    }

    return Column(children: _listTimeWidget);
  }
}
