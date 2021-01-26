import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../common/constants.dart';

class PreviewOverlay extends StatefulWidget {
  final int index;
  final Widget child;

  PreviewOverlay({this.index, this.child});

  @override
  _PreviewOverlayState createState() => _PreviewOverlayState();
}

class _PreviewOverlayState extends State<PreviewOverlay> {
  int previewIndex;
  bool isPreviewing = false;

  @override
  void initState() {
    /// init listener preview index
    eventBus.on<EventPreviewWidget>().listen((event) {
      if (widget.index == event.previewIndex) {
        setState(() {
          previewIndex = event.previewIndex;
          isPreviewing = event.isPreviewing;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const colorPreview = [
      Colors.deepOrange,
      Colors.cyanAccent,
      Colors.deepPurple,
      Colors.pink,
      Colors.lightGreen,
      Colors.amber,
      Colors.indigoAccent,
      Colors.redAccent,
      Colors.teal,
    ];

    if (!isPreviewing) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: previewIndex == widget.index && isPreviewing
                    ? colorPreview[widget.index % colorPreview.length]
                        .withOpacity(0.1)
                    : Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
