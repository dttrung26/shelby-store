import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

import '../../../../../../common/constants.dart';
import '../../../../../../common/tools.dart';
import '../../../../../../generated/l10n.dart';
import '../../product_add_screen_model.dart';
import 'choose_image_widget_model.dart';

export 'choose_image_widget_model.dart';

class ChooseImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _showImageGalleryFromServerBottomSheet() async {
      final model = Provider.of<ChooseImageWidgetModel>(context, listen: false);
      final model2 =
          Provider.of<VendorAdminProductAddScreenModel>(context, listen: false);
      await model.loadImagesFromServer();
      unawaited(showModalBottomSheet(
          context: (context),
          builder: (_) {
            return ChangeNotifierProvider.value(
              value: model,
              child: Consumer<ChooseImageWidgetModel>(
                builder: (context, vendorModel, __) => GridView.builder(
                  shrinkWrap: true,
                  controller: vendorModel.galleryController,
                  cacheExtent: 1000,
                  itemCount: vendorModel.imagesFromServer.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0),
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      model2.updateFeaturedImage(model.imagesFromServer[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.white,
                      child: Tools.image(
                        url: model.imagesFromServer[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }));
    }

    void _showModalBottomSheet() {
      final model = Provider.of<ChooseImageWidgetModel>(context, listen: false);
      final model2 =
          Provider.of<VendorAdminProductAddScreenModel>(context, listen: false);
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        var image = await model.takeImageFromCamera();
                        model2.updateFeaturedImage(image);
                        Navigator.pop(context);
                      },
                      child: Text(S.of(context).takePicture)),
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        var image = await model.chooseImageFromGallery();
                        model2.updateFeaturedImage(image);
                        Navigator.pop(context);
                      },
                      child: Text(S.of(context).chooseFromGallery)),
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        Navigator.pop(context);
                        _showImageGalleryFromServerBottomSheet();
                      },
                      child: Text(S.of(context).chooseFromServer)),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(S.of(context).cancel),
                  isDefaultAction: true,
                ),
              ));
    }

    return Consumer2<ChooseImageWidgetModel, VendorAdminProductAddScreenModel>(
      builder: (context, model, model2, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 15),
          if (model2.featuredImage is String)
            Expanded(
                child: AspectRatio(
              aspectRatio: 6 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: Colors.white,
                  child: Tools.image(
                    url: model2.featuredImage.isNotEmpty
                        ? model2.featuredImage
                        : kDefaultImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )),
          if (model2.featuredImage is PickedFile)
            Expanded(
                child: AspectRatio(
              aspectRatio: 6 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: Colors.white,
                  child: Image.file(
                    File(model2.featuredImage.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )),
          if (model2.featuredImage == null)
            Expanded(
                child: AspectRatio(
              aspectRatio: 6 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: Colors.white,
                  child: Tools.image(
                    url: kDefaultImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )),
          const SizedBox(width: 10),
          InkWell(
            onTap: _showModalBottomSheet,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                S.of(context).selectImage,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
  }
}
