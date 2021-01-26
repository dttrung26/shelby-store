import 'package:flutter/material.dart';

import 'package:zoom_widget/zoom_widget.dart';

class CardZoom extends Zoom {
  final BuildContext context;
  @override
  final Widget child;
  final double maxWidth;
  final double maxHeight;

  CardZoom.story({
    @required this.context,
    @required this.child,
    @required this.maxWidth,
    @required this.maxHeight,
  }) : super(
          width: maxWidth,
          height: maxHeight,
          opacityScrollBars: 0,
          scrollWeight: 0.0,
          centerOnScale: false,
          enableScroll: false,
          doubleTapZoom: false,
          zoomSensibility: 0.0,
          initZoom: 0.0, //scale / MediaQuery.of(context).size.width,
          child: child,
        );
}
