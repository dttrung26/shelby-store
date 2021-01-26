import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../common/constants.dart' show kLoadingWidget;

class FeatureVideoPlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;

  const FeatureVideoPlayer({Key key, this.url, this.autoPlay})
      : super(key: key);

  @override
  _FeatureVideoPlayerState createState() => _FeatureVideoPlayerState();
}

class _FeatureVideoPlayerState extends State<FeatureVideoPlayer> {
  VideoPlayerController _controller;
  bool initialized = false;
  double aspectRatio;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize()
      ..setLooping(true).then((_) {
        if (mounted) {
          setState(() {
            initialized = true;
            aspectRatio = _controller.value.aspectRatio;
          });
        }
      });

    if (widget.autoPlay == true) _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? AspectRatio(
            aspectRatio: aspectRatio ?? _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Container(
            height: MediaQuery.of(context).size.width * 0.8,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(color: Colors.black),
            child: Center(
              child: kLoadingWidget(context),
            ),
          );
  }
}
