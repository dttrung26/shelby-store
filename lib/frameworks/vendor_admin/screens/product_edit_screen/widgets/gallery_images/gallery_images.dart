import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

import '../../../../../../common/tools.dart';
import '../../../../../../generated/l10n.dart';
import '../../product_edit_screen_model.dart';
import 'gallery_images_model.dart';

class VendorAdminProductGalleryImages extends StatelessWidget {
  Widget ImageWidget({dynamic image}) {
    if (image is PickedFile) {
      return Image.file(
        File(image.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
    if (image is Asset) {
      return AssetThumb(
        asset: image,
        width: 100,
        height: 100,
        spinner: Container(
          width: 100,
          height: 100,
        ),
      );
    }

    return Tools.image(
      url: image,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    void _showImageGalleryFromServerBottomSheet() async {
      final model =
          Provider.of<VendorAdminGalleryImagesModel>(context, listen: false);
      final model2 = Provider.of<VendorAdminProductEditScreenModel>(context,
          listen: false);
      await model.loadImagesFromServer();
      unawaited(showModalBottomSheet(
          context: (context),
          builder: (_) {
            return ChangeNotifierProvider.value(
              value: model,
              child: Consumer<VendorAdminGalleryImagesModel>(
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
                      model2.updateGalleryImages(model.imagesFromServer[index]);
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
      final model =
          Provider.of<VendorAdminGalleryImagesModel>(context, listen: false);
      final model2 = Provider.of<VendorAdminProductEditScreenModel>(context,
          listen: false);
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        var image = await model.takeImageFromCamera();
                        model2.updateGalleryImages(image);
                        Navigator.pop(context);
                      },
                      child: Text(S.of(context).takePicture)),
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        var image = await model.chooseImagesFromGallery();
                        model2.updateGalleryImages(image);
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

    return Consumer2<VendorAdminGalleryImagesModel,
        VendorAdminProductEditScreenModel>(
      builder: (context, model, model2, _) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              S.of(context).imageGallery,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Container(
            width: size.width,
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => index == 0
                  ? InkWell(
                      onTap: _showModalBottomSheet,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        width: 100,
                        height: 100,
                        child: const Center(
                          child: Icon(Icons.add_a_photo_outlined),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 1.0,
                                child: ImageWidget(
                                  image: model2.galleryImages[index - 1],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () => model2.removeImageFromGallery(
                                      model2.galleryImages[index - 1]),
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              itemCount: model2.galleryImages.length + 1,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
