import '../../services/index.dart';
import 'booking_controller.dart';

class BookingModel {
  final String idProduct;
  final Services _service = Services();
  final BookingController _bookingController = BookingController();
  BookingModel(this.idProduct) {
    _bookingController.isLoadingSlot = true;
    getListStaff().then((value) {
      updateSlot(DateTime.now())
          .then((value) => _bookingController.isLoadingSlot = false);
    });
  }
  BookingController get controller => _bookingController;

  Future<void> getListStaff() async {
    final listStaff = await _service.api.getListStaff(idProduct);
    if (listStaff?.isNotEmpty ?? false) {
      _bookingController.staffs = listStaff;
    }
  }

  Future<void> updateSlot(DateTime date, [int idStaff]) async {
    _bookingController.isLoadingSlot = true;
    var dateChoose = '${date.year}-${date.month}-${date.day}';
    _bookingController.listSlotSelect.clear();

    final listSlot = await _service.api.getSlotBooking(
      idProduct,
      '$idStaff',
      dateChoose,
    );

    if (listSlot?.isNotEmpty ?? false) {
      _bookingController.listSlotSelect = listSlot;
    }
    _bookingController.isLoadingSlot = false;
  }
}
