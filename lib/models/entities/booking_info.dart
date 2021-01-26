import 'dart:convert' as convert;
import 'staff.dart';

class BookingInfo {
  int month;
  int day;
  int year;
  String timeStart;
  String idProduct;
  String idOrder;
  List<StaffBooking> staffs = [];

  BookingInfo({
    this.month,
    this.day,
    this.year,
    this.timeStart,
    this.idProduct,
    this.idOrder,
    this.staffs,
  });

  bool get isEmpty =>
      month == null ||
      day == null ||
      year == null ||
      timeStart == null ||
      idProduct == null ||
      (staffs?.isEmpty ?? true);

  void setDay(DateTime date) {
    month = date.month;
    year = date.year;
    day = date.day;
    timeStart = null;
  }

  void setHour(int hour) {
    timeStart = '$hour:00';
  }

  bool get isAvaliableOrder => idOrder?.isNotEmpty ?? false;

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'day': day,
      'year': year,
      'timeStart': '$timeStart',
      'idProduct': '$idProduct',
      'idOrder': '$idOrder',
    };
  }

  Map<String, dynamic> toJsonAPI() {
    final listStaff = <int>[];
    if (staffs?.isNotEmpty ?? true) {
      staffs.forEach((element) {
        listStaff.add(element.id);
      });
    }

    return {
      'wc_appointments_field_start_date_month': '$month',
      'wc_appointments_field_start_date_day': '$day',
      'wc_appointments_field_start_date_year': '$year',
      'wc_appointments_field_start_date_time': '$timeStart',
      'wc_appointments_field_addons_duration': '0',
      'wc_appointments_field_addons_cost': '0',
      'product_id': '$idProduct',
      'order_id': '$idOrder',
      'staff_ids': convert.jsonEncode(listStaff),
    };
  }
}
