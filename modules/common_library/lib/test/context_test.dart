import 'package:flutter/material.dart';
import 'package:inspireui/utils/screen_utils.dart';
import 'package:mockito/mockito.dart';

enum MockMediaQueryType {
  defaultSize,
  zeroSize,
  customSize,
}

MediaQueryData _getMediaQueryData(
  MockMediaQueryType mockMediaQueryType,
  MediaQueryData mediaQueryData,
) {
  switch (mockMediaQueryType) {
    case MockMediaQueryType.defaultSize:
      return MediaQueryData(
        size: Size(
          ScreenUtil.defaultWidth.toDouble(),
          ScreenUtil.defaultHeight.toDouble(),
        ),
      );
    case MockMediaQueryType.customSize:
      return mediaQueryData ?? const MediaQueryData();
    default:
      return const MediaQueryData();
  }
}

dynamic _getMediaQuery(
  MockMediaQueryType mockMediaQueryType,
  MediaQueryData mediaQueryData,
) {
  return MediaQuery(
    data: _getMediaQueryData(mockMediaQueryType, mediaQueryData),
    child: Container(),
  );
}

class MockBuildContext extends Mock implements BuildContext {
  final MockMediaQueryType mediaQueryType;
  final MediaQueryData mediaQueryData;

  MockBuildContext({
    this.mediaQueryType = MockMediaQueryType.zeroSize,
    this.mediaQueryData,
  });

  @override
  T dependOnInheritedWidgetOfExactType<T extends InheritedWidget>(
      {Object aspect}) {
    final mediaQuery = _getMediaQuery(mediaQueryType, mediaQueryData);
    if (mediaQuery is T) {
      return mediaQuery;
    }
    return null;
  }
}
