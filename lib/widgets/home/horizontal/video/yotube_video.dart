//import 'package:flutter/material.dart';
//import 'package:visibility_detector/visibility_detector.dart';
//import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//import 'video_controller.dart';
//
//class YoutubeVideo extends StatefulWidget {
//  final config;
//
//  YoutubeVideo({this.config});
//
//  @override
//  _StateYoutubeVideo createState() => _StateYoutubeVideo();
//}
//
//class _StateYoutubeVideo extends State<YoutubeVideo> {
//  YoutubePlayerController _controller;
//
//  @override
//  void initState() {
//    super.initState();
//    _controller = YoutubePlayerController();
//
//    if (widget.config["autoPlay"] == true) _controller.play();
//  }
//
//  @override
//  void dispose() {
//    _controller.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      width: MediaQuery.of(context).size.width,
//      child: Padding(
//        padding: const EdgeInsets.symmetric(horizontal: 10),
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            SizedBox(
//              height: 10,
//            ),
//            YoutubePlayer(
//              context: context,
//              videoId: YoutubePlayer.convertUrlToId(widget.config["url"]),
//              flags: YoutubePlayerFlags(
//                hideControls: true,
//              ),
//              onPlayerInitialized: (controller) {
//                _controller = controller;
//              },
//            ),
//            if (widget.config['showControl'] == true)
//              VideoController(
//                controller: _controller,
//              ),
//            if (widget.config["autoPlay"] == true)
//              VisibilityDetector(
//                key: Key("loading_video"),
//                child: Container(height: 2),
//                onVisibilityChanged: (VisibilityInfo info) {
//                  if (info.visibleFraction == 1.0) {
//                    _controller.play();
//                  } else {
//                    _controller.pause();
//                  }
//                },
//              )
//          ],
//        ),
//      ),
//    );
//  }
//}
