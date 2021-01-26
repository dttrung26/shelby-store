import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/tools.dart';
// import '../index.dart' show Product;

part 'category_icon_config.g.dart';

@JsonSerializable(includeIfNull: false)
class CategoryIconConfig {
  factory CategoryIconConfig.fromJson(Map<String, dynamic> json) =>
      _$CategoryIconConfigFromJson(json);

  Map<String, dynamic> toJson(instance) => _$CategoryIconConfigToJson(this);

  @JsonKey(name: 'category')
  final dynamic id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'image')
  final String imageUrl;

  @JsonKey(name: 'colors', fromJson: HexColor.fromListJson)
  final List<HexColor> colors;

  @JsonKey(name: 'backgroundColor', fromJson: HexColor.fromJson)
  final HexColor backgroundColor;

  // @JsonKey(name: 'data')
  // final List<Product> products;

  CategoryIconConfig({
    this.id,
    this.name,
    this.imageUrl,
    this.colors,
    this.backgroundColor,
    // this.products,
  });

  List<Color> get alphaColors => colors.map((e) => e.withAlpha(30)).toList();

  Color get getBackgroundColor => backgroundColor != null
      ? backgroundColor.withAlpha(30)
      : (colors.length == 1 ? colors.first.withAlpha(30) : null);

  LinearGradient get getGradientColor =>
      getBackgroundColor == null ? LinearGradient(colors: alphaColors) : null;
}
