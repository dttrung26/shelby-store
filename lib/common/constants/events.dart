part of '../constants.dart';

class EventOpenNativeDrawer {
  const EventOpenNativeDrawer();
}

class EventCloseNativeDrawer {
  const EventCloseNativeDrawer();
}

class EventOpenCustomDrawer {
  const EventOpenCustomDrawer();
}

class EventCloseCustomDrawer {
  const EventCloseCustomDrawer();
}

class EventSwitchStateCustomDrawer {
  const EventSwitchStateCustomDrawer();
}

class EventChangeLanguage {
  const EventChangeLanguage();
}

class EventPreviewWidget {
  final int previewIndex;
  final bool isPreviewing;

  const EventPreviewWidget(this.previewIndex, this.isPreviewing);
}
