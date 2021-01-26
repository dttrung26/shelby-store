import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/config.dart' as config;
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';

class OnBoardScreen extends StatefulWidget {
  final appConfig;

  OnBoardScreen(this.appConfig);

  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final isRequiredLogin = config.kLoginSetting['IsRequiredLogin'];
  int page = 0;

  List<Slide> getSlides() {
    final slides = <Slide>[];
    final data = widget.appConfig['OnBoarding'] != null
        ? widget.appConfig['OnBoarding']['data']
        : config.onBoardingData;

    Widget loginWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Image.asset(
          kOrderCompleted,
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  S.of(context).signIn,
                  style: const TextStyle(
                    color: kTeal400,
                    fontSize: 20.0,
                  ),
                ),
                onTap: () async {
                  var prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seen', true);
                  await Navigator.pushNamed(context, RouteList.login);
                },
              ),
              const Text(
                '    |    ',
                style: TextStyle(color: kTeal400, fontSize: 20.0),
              ),
              GestureDetector(
                child: Text(
                  S.of(context).signUp,
                  style: const TextStyle(
                    color: kTeal400,
                    fontSize: 20.0,
                  ),
                ),
                onTap: () async {
                  var prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seen', true);
                  await Navigator.pushNamed(context, RouteList.register);
                },
              ),
            ],
          ),
        ),
      ],
    );

    for (var i = 0; i < data.length; i++) {
      var slide = Slide(
        title: data[i]['title'],
        description: data[i]['desc'],
        marginTitle: const EdgeInsets.only(
          top: 125.0,
          bottom: 50.0,
        ),
        maxLineTextDescription: 2,
        styleTitle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
          color: kGrey900,
        ),
        backgroundColor: Colors.white,
        marginDescription: const EdgeInsets.fromLTRB(20.0, 75.0, 20.0, 0),
        styleDescription: const TextStyle(
          fontSize: 15.0,
          color: kGrey600,
        ),
        foregroundImageFit: BoxFit.fitWidth,
      );

      if (i == 2) {
        slide.centerWidget = loginWidget;
      } else {
        slide.pathImage = data[i]['image'];
      }
      slides.add(slide);
    }
    return slides;
  }

  static const textStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  List<Widget> getPages(List data) {
    return [
      for (int i = 0; i < data.length; i++)
        Container(
          color: HexColor(data[i]['background']),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                data[i]['image'],
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Column(
                children: <Widget>[
                  Text(
                    data[i]['title'],
                    style: textStyle.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data[i]['desc'],
                    style: textStyle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        )
    ];
  }

  Widget _buildDot(int index) {
    var selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page ?? 0) - index).abs(),
      ),
    );
    var zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return Container(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  void pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }

  @override
  Widget build(BuildContext context) {
    String boardType = widget.appConfig['OnBoarding'] != null
        ? widget.appConfig['OnBoarding']['layout']
        : null;

    switch (boardType) {
      case 'liquid':
        return MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: <Widget>[
                LiquidSwipe(
                  fullTransitionValue: 200,
                  enableSlideIcon: true,
                  enableLoop: true,
                  positionSlideIcon: 0.5,
                  onPageChangeCallback: pageChangeCallback,
                  waveType: WaveType.liquidReveal,
                  pages: getPages(widget.appConfig['OnBoarding']['data']),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const Expanded(child: SizedBox()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(5, _buildDot),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return Scaffold(
          backgroundColor: Colors.white,
          body: IntroSlider(
            slides: getSlides(),
            styleNameSkipBtn: const TextStyle(color: kGrey900),
            styleNameDoneBtn: const TextStyle(color: kGrey900),
            namePrevBtn: S.of(context).prev,
            nameSkipBtn: S.of(context).skip,
            nameNextBtn: S.of(context).next,
            nameDoneBtn: isRequiredLogin ? '' : S.of(context).done,
            isShowDoneBtn: !isRequiredLogin,
            onDonePress: () async {
              if (isRequiredLogin) {
                return;
              }
              var prefs = await SharedPreferences.getInstance();
              await prefs.setBool('seen', true);
              await Navigator.pushReplacementNamed(
                  context, RouteList.dashboard);
            },
          ),
        );
    }
  }
}
