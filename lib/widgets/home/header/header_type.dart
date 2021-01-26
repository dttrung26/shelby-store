import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../common/tools.dart';

class HeaderType extends StatelessWidget {
  final config;

  HeaderType({this.config});

  @override
  Widget build(BuildContext context) {
    var _rotate = <String>[];
    var _fontSize = Tools.formatDouble(config['fontSize'] ?? 20.0);

    if (config['rotate'] != null)
      // ignore: curly_braces_in_flow_control_structures
      for (var name in config['rotate']) {
        _rotate.add('$name');
      }

    switch (config['type']) {
      case 'rotate':
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              config['title'],
              style: TextStyle(fontSize: _fontSize),
            ),
            const SizedBox(width: 10.0, height: 20.0),
            RotateAnimatedTextKit(
              text: _rotate,
              repeatForever: true,
              transitionHeight: 40.0,
              textStyle: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case 'fade':
        return SizedBox(
          width: 250.0,
          child: FadeAnimatedTextKit(
            text: _rotate,
            repeatForever: true,
            textStyle:
                TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
          ),
        );
      case 'typer':
        return SizedBox(
          width: 250.0,
          child: TyperAnimatedTextKit(
            text: _rotate,
            textStyle: TextStyle(fontSize: _fontSize),
          ),
        );
      case 'typewriter':
        return SizedBox(
          width: 250.0,
          child: TypewriterAnimatedTextKit(
            text: _rotate,
            repeatForever: true,
            textStyle: TextStyle(fontSize: _fontSize),
          ),
        );
      case 'scale':
        return SizedBox(
          width: 250.0,
          child: ScaleAnimatedTextKit(
            text: _rotate,
            repeatForever: true,
            textStyle: TextStyle(fontSize: _fontSize),
          ),
        );
      case 'color':
        return SizedBox(
          width: 250.0,
          height: 40,
          child: ColorizeAnimatedTextKit(
            onTap: () {},
            text: _rotate,
            repeatForever: true,
            textStyle: TextStyle(fontSize: _fontSize),
            colors: [
              Colors.purple,
              Colors.blue,
              Colors.yellow,
              Colors.red,
            ],
          ),
        );
      case 'animatedSearch':
        return Container(
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: Tools.formatDouble(config['shadow'] ?? 15.0),
                offset: Offset(0, Tools.formatDouble(config['shadow'] ?? 10.0)),
              ),
            ],
            borderRadius: BorderRadius.circular(
              Tools.formatDouble(config['radius'] ?? 30.0),
            ),
            border: Border.all(
              width: 1.0,
              color: Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TypewriterAnimatedTextKit(
                isRepeatingAnimation: true,
                speed: const Duration(milliseconds: 150),
                pause: const Duration(milliseconds: 2000),
                totalRepeatCount: 50,
                text: _rotate,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case 'static':
      default:
        return AutoSizeText(
          config['title'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _fontSize ?? 30,
          ),
          maxLines: 3,
          minFontSize: _fontSize - 10,
          maxFontSize: _fontSize,
          group: AutoSizeGroup(),
        );
    }
  }
}
