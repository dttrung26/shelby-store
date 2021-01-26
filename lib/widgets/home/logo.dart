import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../layout/adaptive.dart';

class Logo extends StatelessWidget {
  final config;

  Logo({
    Key key,
    @required this.config,
  }) : super(key: key);

  Widget renderLogo() {
    if (config['image'] != null) {
      if (config['image'].indexOf('http') != -1) {
        return Tools.image(
          url: config['image'],
          height: 50,
        );
      }
      return Image.asset(
        config['image'],
        height: 40,
      );
    }
    return Image.asset(kLogoImage, height: 40);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final isRotate = screenSize.width > screenSize.height;

    return Builder(
      builder: (context) {
        return Container(
          width: screenSize.width,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Container(
              width: screenSize.width /
                  ((isRotate ? 1.25 : 2) /
                      (screenSize.height / screenSize.width)),
              constraints: const BoxConstraints(
                minHeight: 40.0,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: (config['showMenu'] ?? false)
                          ? IconButton(
                              icon: Icon(
                                Icons.blur_on,
                                color: config['color'] != null
                                    ? HexColor(config['color'])
                                    : Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.9),
                                size: 22,
                              ),
                              onPressed: () {
                                eventBus.fire('drawer');
                                if (isDisplayDesktop(context)) {
                                  eventBus.fire(
                                      const EventSwitchStateCustomDrawer());
                                } else {
                                  eventBus.fire(const EventOpenNativeDrawer());
                                }
                              },
                            )
                          : const SizedBox(),
                    ),
                    Expanded(
                      flex: 8,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 50),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              if (config['showLogo'] ?? false)
                                Center(child: renderLogo()),
                              if ((config['showLogo'] ?? true) &&
                                  config['name'] != null)
                                const SizedBox(
                                  width: 5,
                                ),
                              if (config['name'] != null)
                                Text(
                                  config['name'],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: !(config['showSearch'] ?? false)
                          ? const SizedBox()
                          : IconButton(
                              icon: Icon(
                                Icons.search,
                                color: config['color'] != null
                                    ? HexColor(config['color'])
                                    : Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.6),
                                size: 22,
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(RouteList.homeSearch);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
