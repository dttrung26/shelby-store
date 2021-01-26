import 'package:flutter/material.dart';

import '../entities/booking.dart';
import '../entities/staff.dart';

class BookingController extends ValueNotifier<BookingValue> {
  BookingController({
    List<StaffBooking> staffs,
    String selectDate,
    List<String> listSlotSelect,
  }) : super(
          BookingValue(
            staffs: staffs ?? [],
            selectDate: selectDate ?? '',
            listSlotSelect: listSlotSelect ?? [],
            isLoadingSlot: false,
          ),
        );

  List<StaffBooking> get staffs => value.staffs;
  List<String> get listSlotSelect =>
      (value.listSlotSelect?.isNotEmpty ?? false) ? value.listSlotSelect : [];
  String get selectDate => value.selectDate;
  bool get isLoadingSlot => value.isLoadingSlot;

  set isLoadingSlot(bool isLoadingSlot) {
    value = value.copyWith(isLoadingSlot: isLoadingSlot);
  }

  set staffs(List<StaffBooking> staffs) {
    value.staffs.clear();
    value.staffs.addAll(staffs);
    value = value.copyWith(staffs: value.staffs);
  }

  set listSlotSelect(List<String> listSlotSelect) {
    value = value.copyWith(listSlotSelect: listSlotSelect);
  }

  set selectDate(String selectDate) {
    value = value.copyWith(selectDate: selectDate);
  }

  void clear() {
    value = BookingValue.empty;
  }
}
