import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

import '../../extensions/string_extension.dart';

class ImageRemoteWidget extends StatelessWidget {
  final String urlImage;

  const ImageRemoteWidget({
    Key key,
    @required this.urlImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return urlImage?.isURLImage ?? false
        ? ExtendedImage.network(
            urlImage,
            cache: true,
            fit: BoxFit.cover,
          )
        : const Placeholder();
  }
}
