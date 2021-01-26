import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../models/entities/user.dart';
import '../../../../services/vendor_admin.dart';

enum ChooseImageWidgetModelState { loading, loaded, noMore }

class ChooseImageWidgetModel extends ChangeNotifier {
  /// Service
  final _services = VendorAdminApi();

  /// State
  var state = ChooseImageWidgetModelState.loaded;

  /// Your Other Variables Go Here
  final ImagePicker imagePicker = ImagePicker();
  List<String> imagesFromServer = [];
  int _pageFromServer = 0;
  final int _perPageFromServer = 10;
  User user;
  final ScrollController galleryController = ScrollController();

  /// Constructor
  ChooseImageWidgetModel(this.user) {
    galleryController.addListener(() {
      if (galleryController.position.extentAfter < 300) {
        _loadMoreImagesFromServer();
      }
    });
  }

  /// Update state
  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here

  Future<PickedFile> takeImageFromCamera() async {
    return await imagePicker.getImage(source: ImageSource.camera);
  }

  Future<PickedFile> chooseImageFromGallery() async {
    return await imagePicker.getImage(source: ImageSource.gallery);
  }

  Future<void> loadImagesFromServer() async {
    if (state == ChooseImageWidgetModelState.loading ||
        state == ChooseImageWidgetModelState.noMore) {
      return;
    }
    _updateState(ChooseImageWidgetModelState.loading);

    _pageFromServer++;
    var list = await _services.getImagesByVendor(
        page: _pageFromServer, perPage: _perPageFromServer, vendorId: user.id);
    if (list.isEmpty) {
      _updateState(ChooseImageWidgetModelState.noMore);
      return;
    }
    imagesFromServer.addAll(list);

    _updateState(ChooseImageWidgetModelState.loaded);
  }

  Future<void> _loadMoreImagesFromServer() async {
    if (state == ChooseImageWidgetModelState.loading ||
        state == ChooseImageWidgetModelState.noMore) {
      return;
    }

    _updateState(ChooseImageWidgetModelState.loading);

    _pageFromServer++;

    var list = await _services.getImagesByVendor(
        page: _pageFromServer, perPage: _perPageFromServer, vendorId: user.id);
    if (list.isEmpty) {
      _updateState(ChooseImageWidgetModelState.noMore);
      return;
    }
    imagesFromServer.addAll(list);

    _updateState(ChooseImageWidgetModelState.loaded);
  }
}
