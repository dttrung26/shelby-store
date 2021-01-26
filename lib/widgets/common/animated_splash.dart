import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Function _next;
Function _customFunction;
String _imagePath;
int _duration;
AnimatedSplashType _runfor;
bool _isPushNext;

enum AnimatedSplashType { StaticDuration, BackgroundProcess }

Map<dynamic, Widget> _outputAndHome = {};

class AnimatedSplash extends StatefulWidget {
  AnimatedSplash({
    @required String imagePath,
    @required Function next,
    Function customFunction,
    @required int duration,
    AnimatedSplashType type,
    Map<dynamic, Widget> outputAndHome,
    bool isPushNext = true,
  }) {
    assert(duration != null);
    assert(imagePath != null);
    _next = next;
    _duration = duration;
    _customFunction = customFunction;
    _imagePath = imagePath;
    _runfor = type;
    _outputAndHome = outputAndHome;
    _isPushNext = isPushNext;
  }

  @override
  _AnimatedSplashState createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    if (_duration < 1000) _duration = 2000;
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInCirc));
    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.reset();
  }

  void navigator(home) {
    _next();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPushNext) {
      _runfor == AnimatedSplashType.BackgroundProcess
          ? Future.delayed(Duration.zero).then((value) {
              var res = _customFunction();
              //print("$res+${_outputAndHome[res]}");
              Future.delayed(Duration(milliseconds: _duration)).then((value) {
                Navigator.of(context).pushReplacement(CupertinoPageRoute(
                    builder: (BuildContext context) => _outputAndHome[res]));
              });
            })
          : Future.delayed(Duration(milliseconds: _duration)).then((value) {
              _next();
            });
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: FadeTransition(
            opacity: _animation,
            child: Center(
              child: Image.asset(_imagePath),
            )));
  }
}
