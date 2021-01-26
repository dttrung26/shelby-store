import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GetCameraImage extends StatefulWidget {
  @override
  _StateGetCameraImage createState() => _StateGetCameraImage();
}

class _StateGetCameraImage extends State<GetCameraImage> {
  File image;
  final picker = ImagePicker();

  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.camera);
    setState(() {
      this.image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.grey,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
            child: image != null
                ? Image.file(image)
                : const Icon(
                    Icons.image,
                    size: 60,
                  ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: getImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'Camera',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context, image);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      'Save',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
