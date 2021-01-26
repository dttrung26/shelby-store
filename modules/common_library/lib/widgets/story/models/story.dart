import 'package:flutter/material.dart';

enum TypographyFontStyle { underline, bold, italic, line, none }

enum TypographyTransform { uper, lower, full, normal }

class Story {
  int layout;
  String urlImage;
  List<StoryContent> contents;

  Story({
    this.layout,
    this.urlImage,
    this.contents,
  });

  Story.fromJson(Map<dynamic, dynamic> json) {
    layout = json['layout'] ?? '';
    urlImage = json['urlImage'] ?? '';
    contents = [];
    if (json['contents'] != null && json['contents'].isNotEmpty) {
      for (final item in json['contents']) {
        contents.add(StoryContent.fromJson(item));
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'layout': layout ?? '',
      'urlImage': urlImage ?? '',
      'contents': contents != null && contents.isNotEmpty
          ? contents.map((content) => content.toJson()).toList()
          : []
    };
  }
}

class StoryContent {
  String title;
  EdgeInsets padding;
  StoryLink link;
  StoryTypography typography;
  StoryAnimation animation;
  StorySpacing spacing;

  StoryContent({
    this.title,
    this.padding,
    this.link,
    this.typography,
    this.animation,
    this.spacing,
  });

  StoryContent.empty() {
    title = 'Text';
    padding = const EdgeInsets.all(0);
    link = StoryLink.createEmpty;
    animation = StoryAnimation.createEmpty;
    spacing = StorySpacing.createEmpty;
    typography = StoryTypography.createEmpty;
  }

  String getTitle() {
    if (typography == null || (typography.transform?.isEmpty ?? true)) {
      return title;
    }

    switch (typography.transform) {
      case 'lower':
        return title.toLowerCase();
      case 'uper':
        return toUpperAllFirstLetter(title);
      case 'full':
        return title.toUpperCase();
      default:
        return title;
    }
  }

  String toUpperAllFirstLetter(String text) {
    if (text.length <= 1) {
      return text.toUpperCase();
    }
    text = text.toLowerCase();

    final words = text.split(' ');
    final capitalized = words.map((word) {
      final first = word.substring(0, 1).toUpperCase();
      final rest = word.substring(1);
      return '$first$rest';
    });
    return capitalized.join(' ');
  }

  EdgeInsets getPadding(double widthScreen) {
    if (padding == null) {
      return padding;
    }
    return EdgeInsets.only(
      top: padding.top != null ? (padding.top * widthScreen) : 0,
      bottom: padding.bottom != null ? (padding.bottom * widthScreen) : 0,
      left: padding.left != null ? (padding.left * widthScreen) : 0,
      right: padding.right != null ? (padding.right * widthScreen) : 0,
    );
  }

  StoryContent.fromJson(Map<dynamic, dynamic> json) {
    title = json['title'] ?? '';

    if (json['link'] != null) {
      link = StoryLink.fromJson(json['link']);
    }

    if (json['typography'] != null) {
      typography = StoryTypography.fromJson(json['typography']);
    }

    if (json['animation'] != null) {
      animation = StoryAnimation.fromJson(json['animation']);
    }

    if (json['spacing'] != null) {
      spacing = StorySpacing.fromJson(json['spacing']);
    }
    if (json['paddingContent'] != null) {
      padding = EdgeInsets.only(
        top: json['paddingContent']['top'],
        bottom: json['paddingContent']['bottom'],
        left: json['paddingContent']['left'],
        right: json['paddingContent']['right'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    var _padding = {};

    if (padding != null) {
      _padding = {
        'top': padding.top,
        'bottom': padding.bottom,
        'left': padding.left,
        'right': padding.right,
      };
    }
    return {
      'title': title ?? '',
      'link': link.toJson() ?? '',
      'typography': typography.toJson() ?? '',
      'animation': animation.toJson() ?? '',
      'spacing': spacing.toJson() ?? '',
      'paddingContent': _padding ?? '',
    };
  }
}

class StoryLink {
  String value;
  String type;
  String tag;

  StoryLink({this.value, this.type, this.tag});

  bool get isNotEmpty =>
      (value?.isNotEmpty ?? false) && (type?.isNotEmpty ?? false);
// ignore: prefer_constructors_over_static_methods
  static StoryLink get createEmpty => StoryLink(value: '', type: '', tag: '');

  StoryLink.fromJson(Map<dynamic, dynamic> json) {
    value = json['value'] ?? '';
    type = json['type'] ?? '';
    tag = json['tag'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value ?? '',
      'type': type ?? '',
      'tag': tag ?? '',
    };
  }
}

class StoryTypography {
  String font;
  double fontSize;
  String fontStyle;
  String align;
  String transform;

  StoryTypography({
    this.font,
    this.fontSize,
    this.fontStyle,
    this.align,
    this.transform,
  });
// ignore: prefer_constructors_over_static_methods
  static StoryTypography get createEmpty => StoryTypography(
        font: 'Roboto',
        fontSize: 15,
        fontStyle: 'normal',
        align: 'center',
        transform: 'nomarl',
      );

  StoryTypography.fromJson(Map<dynamic, dynamic> json) {
    font = json['font'] ?? 'Roboto';
    fontSize = json['fontSize'] ?? '';
    fontStyle = json['fontStyle'] ?? '';
    align = json['align'] ?? '';
    transform = json['transform'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'font': font ?? 'Roboto',
      'fontSize': fontSize ?? 15,
      'fontStyle': fontStyle ?? '',
      'align': align ?? '',
      'transform': transform ?? ''
    };
  }

  TextAlign convertStringToAlign() {
    switch (align) {
      case 'center':
        return TextAlign.center;
        break;
      case 'left':
        return TextAlign.left;
        break;
      case 'right':
        return TextAlign.right;
        break;
      case 'justify':
        return TextAlign.justify;
        break;
      default:
        return TextAlign.left;
    }
  }

  FontStyle convertStringToStyle() {
    switch (fontStyle) {
      case 'italic':
        return FontStyle.italic;
        break;
      default:
        return FontStyle.normal;
    }
  }

  TextDecoration convertStringToDecoration() {
    switch (fontStyle) {
      case 'underline':
        return TextDecoration.underline;
        break;
      case 'line':
        return TextDecoration.overline;
        break;
      default:
        return TextDecoration.none;
    }
  }

  FontWeight convertStringToWeight() {
    switch (fontStyle) {
      case 'bold':
        return FontWeight.bold;
        break;
      default:
        return FontWeight.normal;
    }
  }

  TypographyTransform convertStringToTransform() {
    switch (transform) {
      case 'lower':
        return TypographyTransform.lower;
        break;
      case 'uper':
        return TypographyTransform.uper;
        break;
      case 'full':
        return TypographyTransform.full;
        break;
      default:
        return TypographyTransform.normal;
    }
  }

  void updateFontStyle(TypographyFontStyle style) {
    switch (style) {
      case TypographyFontStyle.underline:
        fontStyle = 'underline';
        break;
      case TypographyFontStyle.bold:
        fontStyle = 'bold';
        break;
      case TypographyFontStyle.italic:
        fontStyle = 'italic';
        break;
      case TypographyFontStyle.line:
        fontStyle = 'line';
        break;
      default:
        fontStyle = 'none';
    }
  }

  TypographyFontStyle getFontStyle() {
    switch (fontStyle) {
      case 'underline':
        return TypographyFontStyle.underline;
        break;
      case 'bold':
        return TypographyFontStyle.bold;
        break;
      case 'italic':
        return TypographyFontStyle.italic;
        break;
      case 'line':
        return TypographyFontStyle.line;
        break;
      default:
        return TypographyFontStyle.none;
    }
  }

  void updateAlign(TextAlign alg) {
    switch (alg) {
      case TextAlign.center:
        align = 'center';
        break;
      case TextAlign.right:
        align = 'right';
        break;
      case TextAlign.justify:
        align = 'justify';
        break;
      default:
        align = 'left';
    }
  }

  void updateTransform(TypographyTransform transf) {
    switch (transf) {
      case TypographyTransform.lower:
        transform = 'lower';
        break;
      case TypographyTransform.uper:
        transform = 'uper';
        break;
      default:
        transform = 'full';
    }
  }
}

class StoryAnimation {
  String type;
  int milliseconds;
  int delaySecond;

  StoryAnimation({
    this.type,
    this.milliseconds,
    this.delaySecond,
  });
  // ignore: prefer_constructors_over_static_methods
  static StoryAnimation get createEmpty =>
      StoryAnimation(type: '', milliseconds: 300, delaySecond: 0);
  StoryAnimation.fromJson(Map<dynamic, dynamic> json) {
    type = json['type'] ?? '';
    milliseconds = json['milliseconds'] ?? 300;
    delaySecond = json['delaySecond'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type ?? '',
      'milliseconds': milliseconds ?? 300,
      'delaySecond': delaySecond ?? 0,
    };
  }
}

class StorySpacing {
  EdgeInsets padding;
  EdgeInsets margin;

  StorySpacing({
    this.padding = const EdgeInsets.all(0),
    this.margin = const EdgeInsets.all(0),
  });

// ignore: prefer_constructors_over_static_methods
  static StorySpacing get createEmpty => StorySpacing(
      padding: const EdgeInsets.all(0), margin: const EdgeInsets.all(0));

  StorySpacing.fromJson(Map<dynamic, dynamic> json) {
    if (json['padding'] != null) {
      padding = EdgeInsets.only(
        top: json['padding']['top'] != null ? (json['padding']['top']) : 0,
        bottom: json['padding']['bottom'] ?? 0,
        left: json['padding']['left'] ?? 0,
        right: json['padding']['right'] ?? 0,
      );
    }

    if (json['margin'] != null) {
      margin = EdgeInsets.only(
        top: json['margin']['top'] != null ? (json['margin']['top']) : 0,
        bottom: json['margin']['bottom'] ?? 0,
        left: json['margin']['left'] ?? 0,
        right: json['margin']['right'] ?? 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    var _padding = {};

    if (padding != null) {
      _padding = {
        'top': padding.top,
        'bottom': padding.bottom,
        'left': padding.left,
        'right': padding.right,
      };
    }

    var result = {};
    if (margin != null) {
      result = {
        'top': margin.top,
        'bottom': margin.bottom,
        'left': margin.left,
        'right': margin.right,
      };
    }
    return {'padding': _padding, 'margin': result};
  }
}
