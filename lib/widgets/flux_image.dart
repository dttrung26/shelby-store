import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import '../common/constants.dart';
import 'loading_widget.dart';

class FluxImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Color color;

  const FluxImage({
    @required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    var imageProxy = '';
    if (!imageUrl.contains('http')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
      );
    }

    if (kIsWeb) imageProxy = kImageProxy;

    return ExtendedImage.network(
      '$imageProxy$imageUrl',
      width: width,
      height: height,
      fit: fit,
      color: color,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return kIsWeb ? const SizedBox() : const LoadingWidget();
          case LoadState.failed:
            return const SizedBox();
          case LoadState.completed:
            return state.completedWidget;
          default:
            return const SizedBox();
        }
      },
    );
  }
}
