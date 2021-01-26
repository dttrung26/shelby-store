// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

enum DisplayType {
  desktop,
  tablet,
  mobile,
}

const _desktopBreakpointWstH = 1024.0; // Width is smaller than Height
const _desktopBreakpointWgtH = 700.0; // Width is greater than Height

/// Returns the [DisplayType] for the current screen. This app only supports
/// mobile and desktop layouts, and as such we only have one breakpoint.
DisplayType displayTypeOf(BuildContext context) {
  if ((MediaQuery.of(context).size.width < MediaQuery.of(context).size.height &&
          MediaQuery.of(context).size.width <= _desktopBreakpointWstH) ||
      (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height &&
          MediaQuery.of(context).size.width <= _desktopBreakpointWgtH)) {
    return DisplayType.mobile;
  } else {
    return DisplayType.desktop;
  }
}

/// Returns a boolean if we are in a display of [DisplayType.desktop]. Used to
/// build adaptive and responsive layouts.
bool isDisplayDesktop(BuildContext context) {
  // if (Config().isBuilder) return false;
  // return displayTypeOf(context) == DisplayType.desktop;
  final deviceType = getDeviceType(MediaQuery.of(context).size);
  return deviceType == DeviceScreenType.desktop ||
      (deviceType == DeviceScreenType.tablet &&
          MediaQuery.of(context).orientation == Orientation.landscape);
}

bool isBigScreen(BuildContext context) {
  // if (Config().isBuilder) return true;
  return MediaQuery.of(context).size.width >= 768;
}
