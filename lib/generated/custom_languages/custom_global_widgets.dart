import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CustomGlobalWidgetsLocalizations implements WidgetsLocalizations {
  CustomGlobalWidgetsLocalizations(this.locale) {
    final language = locale.languageCode.toLowerCase();
    _textDirection = _rtlLanguages.contains(language)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  // See http://en.wikipedia.org/wiki/Right-to-left
  static const List<String> _rtlLanguages = <String>[
    'ar', // Arabic
    'fa', // Farsi
    'he', // Hebrew
    'ps', // Pashto
    'ur', // Urdu
    'ku', // Kurdish
  ];

  final Locale locale;

  @override
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;

  static Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(
        CustomGlobalWidgetsLocalizations(locale));
  }

  static const LocalizationsDelegate<WidgetsLocalizations> delegate =
      _WidgetsLocalizationsDelegate();
}

class _WidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _WidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      CustomGlobalWidgetsLocalizations.load(locale);

  @override
  bool shouldReload(_WidgetsLocalizationsDelegate old) => false;

  @override
  String toString() => 'GlobalWidgetsLocalizations.delegate(all locales)';
}
