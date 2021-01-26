import 'staff.dart';

class BookingValue {
  List<StaffBooking> staffs;
  String selectDate;
  List<String> listSlotSelect;
  bool isLoadingSlot;

  BookingValue({
    this.staffs,
    this.selectDate,
    this.listSlotSelect,
    this.isLoadingSlot = false,
  });

  static BookingValue empty = BookingValue(
    staffs: [],
    selectDate: '',
    listSlotSelect: [],
    isLoadingSlot: false,
  );

  BookingValue copyWith({
    List<StaffBooking> staffs,
    String selectDate,
    List<String> listSlotSelect,
    bool isLoadingSlot,
  }) {
    return BookingValue(
      staffs: staffs ?? this.staffs,
      selectDate: selectDate ?? this.selectDate,
      listSlotSelect: listSlotSelect ?? this.listSlotSelect,
      isLoadingSlot: isLoadingSlot ?? this.isLoadingSlot,
    );
  }
}
