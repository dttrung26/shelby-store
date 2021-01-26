import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspireui/test/material_test.dart';
import 'package:inspireui/test/navigate_test.dart';
import 'package:inspireui/utils/screen_utils.dart';
import 'package:inspireui/extensions/screen_utils_extensions.dart';

NavigatorObserver mockObserver;

void main() {
  BuildContext mockContext;

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  Future<void> _buildMockContext(WidgetTester tester) async {
    await tester.pumpWidget(Builder(builder: (BuildContext context) {
      return wrapWidget(Scaffold(
        body: MaterialApp(
          builder: (BuildContext context, Widget widget) {
            mockContext = context;
            return Container();
          },
        ),
      ), mockObserver);
    }));
  }

  group('Screen utils extenstion ', () {
    testWidgets('set width ', (WidgetTester tester) async {
      // Given
      await _buildMockContext(tester);
      // When
      ScreenUtil.init(mockContext);
      // Then
      const width = 100;
      final expectedWidth = width * ScreenUtil().scaleWidth;
      expect(width.w, expectedWidth);
    });

    testWidgets('set height in pixel ', (WidgetTester tester) async {
      // Given
      await _buildMockContext(tester);
      // When
      ScreenUtil.init(mockContext);
      // Then
      const height = 200;
      final expectedHeight = height * ScreenUtil().scaleHeight;
      expect(height.h, expectedHeight);
    });

    testWidgets('should scale font ', (WidgetTester tester) async {
      // Given
      await _buildMockContext(tester);
      // When
      ScreenUtil.init(mockContext);
      // Then
      const fontSize = 20.0;
      final expectedScaledFont =
          (fontSize * ScreenUtil().scaleText) / ScreenUtil.textScaleFactor;
      expect(fontSize.sp, expectedScaledFont);
    });
  });
}
