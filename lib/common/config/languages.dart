part of '../config.dart';


/// Download from https://github.com/hjnilsson/country-flags/tree/master/png100px
class ImageCountry {
  static const String GB = 'assets/images/country/gb.png'; // English
  static const String VN = 'assets/images/country/vn.png'; // Vietnam
  static const String JA = 'assets/images/country/ja.png'; // Japan
  static const String ZH = 'assets/images/country/zh.png'; // China
  static const String ES = 'assets/images/country/es.png'; // Spanish
  static const String AR = 'assets/images/country/ar.png'; // Arabic
  static const String RO = 'assets/images/country/ro.png'; // Romania
  static const String TR = 'assets/images/country/tr.png'; // Turkey
  static const String IT = 'assets/images/country/it.png'; // Italy
  static const String ID = 'assets/images/country/id.png'; // Indonesia
  static const String DE = 'assets/images/country/de.png'; // German
  static const String BR = 'assets/images/country/br.png'; // Brazil
  static const String FR = 'assets/images/country/fr.png'; // France
  static const String HU = 'assets/images/country/hu.png'; // Hungary
  static const String RU = 'assets/images/country/ru.png'; // Russian
  static const String TH = 'assets/images/country/th.png'; // Thailand
  static const String HE = 'assets/images/country/he.png'; // Israel/Hebrew
  static const String KR = 'assets/images/country/kr.png'; // Korean
  static const String NL = 'assets/images/country/nl.png'; // Netherlands/Dutch
  static const String IN = 'assets/images/country/in.png'; // India/Hindi
  static const String KU = 'assets/images/country/ku.png'; // Kurdish
}

/// Supported language
/// https://api.flutter.dev/flutter/flutter_localizations/GlobalMaterialLocalizations-class.html
List<Map<String, dynamic>> getLanguages([context]) {
  return [
    {
      'name': context != null ? S.of(context).english : 'English',
      'icon': ImageCountry.GB,
      'code': 'en',
      'text': 'English',
      'storeViewCode': ''
    },
    {
      'name': context != null ? S.of(context).chinese : 'Chinese',
      'icon': ImageCountry.ZH,
      'code': 'zh',
      'text': 'Chinese',
      'storeViewCode': ''
    },
    {
      'name': context != null ? S.of(context).India : 'Hindi',
      'icon': ImageCountry.IN,
      'code': 'hi',
      'text': 'Hindi',
      'storeViewCode': 'hi'
    },
    {
      'name': context != null ? S.of(context).spanish : 'Spanish',
      'icon': ImageCountry.ES,
      'code': 'es',
      'text': 'Spanish',
      'storeViewCode': ''
    },
    {
      'name': context != null ? S.of(context).french : 'French',
      'icon': ImageCountry.FR,
      'code': 'fr',
      'text': 'French',
      'storeViewCode': 'fr'
    },
    {
      'name': context != null ? S.of(context).arabic : 'Arabic',
      'icon': ImageCountry.AR,
      'code': 'ar',
      'text': 'Arabic',
      'storeViewCode': 'ar'
    },
    {
      'name': context != null ? S.of(context).russian : 'Russian',
      'icon': ImageCountry.RU,
      'code': 'ru',
      'text': 'Русский',
      'storeViewCode': 'ru'
    },
    {
      'name': context != null ? S.of(context).indonesian : 'Indonesian',
      'icon': ImageCountry.ID,
      'code': 'id',
      'text': 'Indonesian',
      'storeViewCode': 'id'
    },
    {
      'name': context != null ? S.of(context).japanese : 'Japanese',
      'icon': ImageCountry.JA,
      'code': 'ja',
      'text': 'Japanese',
      'storeViewCode': ''
    },
    {
      'name': context != null ? S.of(context).Korean : 'Korean',
      'icon': ImageCountry.KR,
      'code': 'kr',
      'text': 'Korean',
      'storeViewCode': 'kr'
    },
    {
      'name': context != null ? S.of(context).vietnamese : 'Vietnamese',
      'icon': ImageCountry.VN,
      'code': 'vi',
      'text': 'Vietnam',
      'storeViewCode': ''
    },
    {
      'name': context != null ? S.of(context).romanian : 'Romanian',
      'icon': ImageCountry.RO,
      'code': 'ro',
      'text': 'Romanian',
      'storeViewCode': 'ro'
    },
    {
      'name': context != null ? S.of(context).turkish : 'Turkish',
      'icon': ImageCountry.TR,
      'code': 'tr',
      'text': 'Turkish',
      'storeViewCode': 'tr'
    },
    {
      'name': context != null ? S.of(context).italian : 'Italian',
      'icon': ImageCountry.IT,
      'code': 'it',
      'text': 'Italian',
      'storeViewCode': 'it'
    },
    {
      'name': context != null ? S.of(context).german : 'German',
      'icon': ImageCountry.DE,
      'code': 'de',
      'text': 'German',
      'storeViewCode': 'de'
    },
    {
      'name': context != null ? S.of(context).brazil : 'Portuguese',
      'icon': ImageCountry.BR,
      'code': 'pt',
      'text': 'Portuguese',
      'storeViewCode': 'pt'
    },
    {
      'name': context != null ? S.of(context).hungary : 'Hungarian',
      'icon': ImageCountry.HU,
      'code': 'hu',
      'text': 'Hungarian',
      'storeViewCode': 'hu'
    },
    {
      'name': context != null ? S.of(context).hebrew : 'Hebrew',
      'icon': ImageCountry.HE,
      'code': 'he',
      'text': 'Hebrew',
      'storeViewCode': 'he'
    },
    {
      'name': context != null ? S.of(context).thailand : 'Thai',
      'icon': ImageCountry.TH,
      'code': 'th',
      'text': 'Thai',
      'storeViewCode': 'th'
    },
    {
      'name': context != null ? S.of(context).Dutch : 'Dutch',
      'icon': ImageCountry.NL,
      'code': 'nl',
      'text': 'Dutch',
      'storeViewCode': 'nl'
    },

    /// Vendor admin does not support unofficial languages (such as Kurdish...)
    if (serverConfig['type'] != 'vendorAdmin')
      {
        'name': 'Kurdish',
        'icon': ImageCountry.KU,
        'code': 'ku',
        'text': 'Kurdish',
        'storeViewCode': 'ku'
      }
  ];
}

/// For Vendor Admin
List<String> unsupportedLanguages = ['ku'];
