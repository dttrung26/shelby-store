import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../../../models/index.dart';
import '../calendar/calendar.dart';
import '../choose_time/choose_time_widget.dart';
import 'booking_constants.dart';

class BookingWidget extends StatefulWidget {
  final Function(BookingInfo) onBooking;
  final Function(DateTime date, int idStaff) updateSlot;
  final String idProduct;
  final BookingController controller;
  final Widget loadingWidget;

  BookingWidget({
    Key key,
    @required this.idProduct,
    @required this.controller,
    this.updateSlot,
    this.onBooking,
    this.loadingWidget,
  }) : super(key: key);

  @override
  _BookingWidgetState createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  BookingController get _controller => widget.controller;
  bool get _staffNotEmpty => _controller.staffs?.isNotEmpty ?? false;

  DateTime get _startTime =>
      (widget.controller.listSlotSelect?.isNotEmpty ?? false)
          ? DateTime.parse(widget.controller.listSlotSelect.first)
          : null;
  DateTime get _endTime =>
      (widget.controller.listSlotSelect?.isNotEmpty ?? false)
          ? DateTime.parse(widget.controller.listSlotSelect.last)
          : null;

  final BookingInfo _info = BookingInfo();
  final List<StaffBooking> _listStaff = [];
  DateTime _currentDate = DateTime.now();
  StaffBooking _staff;
  int hour;

  @override
  void initState() {
    hour = _currentDate.hour;

    _info
      ..staffs ??= []
      ..setDay(_currentDate)
      ..idProduct = widget.idProduct;

    if (_staffNotEmpty) {
      _staff = _controller.staffs[0];
      _listStaff.addAll(_controller.staffs);
      _info.staffs
        ..clear()
        ..add(_staff);
    }

    _controller.addListener(_changeUIByController);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_changeUIByController);
    super.dispose();
  }

  void _changeUIByController() {
    if (_controller.staffs?.isNotEmpty ?? false) {
      _listStaff.clear();
      _listStaff.addAll(_controller.staffs);
      _info.staffs
        ..clear()
        ..add(_staff);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownSearch<StaffBooking>(
            mode: Mode.MENU,
            items: _listStaff,
            label: 'Choose Staff',
            showClearButton: true,
            onChanged: (value) {
              _staff = value;
              widget.updateSlot?.call(_currentDate, _staff?.id);
            },
            selectedItem: _staff,
            dropdownBuilder: (context, selectedItem, itemAsString) {
              return Text('${selectedItem?.displayName ?? ''}');
            },
            dropdownBuilderSupportsNullItem: true,
            popupItemBuilder: (context, item, isSelected) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Text('${item?.displayName ?? ''}'),
              );
            },
            clearButton: const Icon(Icons.clear_sharp),
            // emptyBuilder: (context) {
            //   return Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 10),
            //     child: Text('Not found staff'),
            //   );
            // },
            showSearchBox: true,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).buttonTheme.colorScheme.onPrimary,
                    style: BorderStyle.solid,
                    width: 0.5,
                  ),
                ),
              ),
              child: CalendarWidget.booking(
                context,
                key: const ValueKey(BookingConstants.keyBookingChangeDate),
                selectedDateTime: _currentDate,
                onDayPressed: (DateTime date, events) {
                  _info.setDay(date);
                  // hour = null;
                  widget.updateSlot?.call(date, _staff?.id);
                  setState(() => _currentDate = date);
                },
              ),
            ),
          ),
          _renderSlotTime(),
          RaisedButton(
            key: const ValueKey(BookingConstants.keyBookingNow),
            child: const Text('Booking now'),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            elevation: 0.1,
            onPressed: _info.isEmpty || (_staff == null)
                ? null
                : () => widget.onBooking?.call(_info),
          )
        ],
      ),
    );
  }

  Widget kLoading() {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget;
    }
    return const SizedBox(
      child: CircularProgressIndicator(),
      width: 50,
      height: 50,
    );
  }

  Widget _renderSlotTime() {
    if (_controller.isLoadingSlot) {
      return Container(height: 300, child: Center(child: kLoading()));
    }

    return ChooseTimeWidget(
      key: ValueKey('${_controller.selectDate}_keyChooseTime'),
      initValue: hour,
      startTime: _startTime,
      endTime: _endTime,
      selectDate: _currentDate,
      onChooseTime: (hourChoose) {
        hour = hourChoose;
        _info.setHour(hourChoose);
        setState(() {});
      },
    );
  }
}
