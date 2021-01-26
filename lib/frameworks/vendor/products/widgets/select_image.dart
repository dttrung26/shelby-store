import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../screens/choose_image/network_image.dart';

class SelectImage extends StatelessWidget {
  final Function(List<File>, List<String>) onSelect;
  final Function(bool isLoading) isLoading;
  final List<File> fileImages;
  final List<String> networkImages;

  SelectImage({
    Key key,
    this.onSelect,
    this.isLoading,
    this.fileImages,
    this.networkImages,
  }) : super(key: key);

  Future _getImageFromCamera() async {
    isLoading(true);
    var pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70);
    var image = File(pickedFile.path);

    if (image != null) {
      var path = image.path;
      var _image = img.decodeImage(image.readAsBytesSync());

      path = path.substring(0, path.lastIndexOf('.')) + '.png';
      await image.rename(path).then((onValue) {
        onValue.writeAsBytesSync(img.encodePng(_image));
        fileImages.add(onValue);
      });
      onSelect(fileImages, networkImages);
    }
    isLoading(false);
  }

  Future _getImageFromGallery() async {
    isLoading(true);
    var pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (pickedFile == null) {
      isLoading(false);
      return;
    }

    var image = File(pickedFile.path);

    if (image != null) {
      if (isIos) {
        var path = image.path;
        var _image = img.decodeImage(image.readAsBytesSync());

        path = path.substring(0, path.lastIndexOf('.')) + '.png';
        await image.rename(path).then((onValue) {
          onValue.writeAsBytesSync(img.encodePng(_image));
          fileImages.add(onValue);
        });
      } else {
        fileImages.add(image);
      }
      onSelect(fileImages, networkImages);
    }
    isLoading(false);
  }

  void _getNetworkImage(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GetNetworkImage(),
        )).then((result) {
      if (result != null) {
        networkImages.add(result.toString());
        onSelect(fileImages, networkImages);
        // setState(() {});
      }
    });
  }

  void _showOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.only(bottom: 150, left: 20, right: 20, top: 20),
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.image,
                      size: 60,
                    ),
                    const Text(
                      'Gallery',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.camera_alt,
                      size: 60,
                    ),
                    const Text(
                      'Camera',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getNetworkImage(context);
                },
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.broken_image,
                      size: 60,
                    ),
                    const Text(
                      'Network',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  List<Widget> _renderListImage() {
    return List.generate(
      networkImages.length + fileImages.length,
      (index) {
        Widget _image;
        var _onTapClose;

        if (networkImages.length > index) {
          _image = Image.network(
            networkImages[index],
            width: 150,
          );

          _onTapClose = () {
            networkImages.removeAt(index);
            onSelect(fileImages, networkImages);
          };
        } else {
          _image = Image.file(
            fileImages[index - networkImages.length],
          );

          _onTapClose = () {
            fileImages.removeAt(index - networkImages.length);
            onSelect(fileImages, networkImages);
          };
        }

        return Container(
          margin: const EdgeInsets.only(right: 10),
          child: Stack(
            children: <Widget>[
              _image,
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  child: GestureDetector(
                    onTap: _onTapClose,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: Text(
              S.of(context).imageGallery,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            )),
            const SizedBox(
              width: 30,
            ),
            GestureDetector(
              onTap: () {
                _showOption(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    const BoxShadow(color: Colors.grey, blurRadius: 5)
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        if (networkImages.length + fileImages.length > 0)
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColorLight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _renderListImage()),
            ),
          ),
        if (networkImages.length + fileImages.length <= 0)
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColorLight,
            alignment: AlignmentDirectional.center,
            child: Text(
              S.of(context).addingYourImage,
              style: const TextStyle(fontWeight: FontWeight.w200),
            ),
          )
      ],
    );
  }
}
