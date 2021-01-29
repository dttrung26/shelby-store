import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveSplashScreen extends StatefulWidget {
  final Function onSuccess;
  final String asset;
  final Color color;
  final String animationName;
  const RiveSplashScreen({
    Key key,
    @required this.onSuccess,
    @required this.asset,
    @required this.animationName,
    this.color,
  }) : super(key: key);
  @override
  _RiveSplashScreenState createState() => _RiveSplashScreenState();
}

class _RiveSplashScreenState extends State<RiveSplashScreen> {
  Artboard _riveArtboard;
  RiveAnimationController _controller;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      rootBundle.load(widget.asset).then(
        (data) async {
          final file = RiveFile();

          if (file.import(data)) {
            final artboard = file.mainArtboard;
            artboard.addController(
                _controller = SimpleAnimation(widget.animationName));
            setState(() {
              _riveArtboard = artboard;
            });
            Future.delayed(const Duration(milliseconds: 1500))
                .then((value) => widget.onSuccess());
            // _controller.isActiveChanged.addListener(() {
            //   if (!_controller.isActive) {
            //     Future.delayed(const Duration(seconds: 1))
            //         .then((value) => widget.onSuccess());
            //   }
            // });
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Center(
        child: _riveArtboard == null
            ? const SizedBox()
            : Rive(artboard: _riveArtboard),
      ),
    );
  }
}
