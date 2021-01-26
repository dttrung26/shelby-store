// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_icon_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryIconConfig _$CategoryIconConfigFromJson(Map<String, dynamic> json) {
  return CategoryIconConfig(
    id: json['category'],
    name: json['name'] as String,
    imageUrl: json['image'] as String,
    colors: HexColor.fromListJson(json['colors'] as List),
    backgroundColor: HexColor.fromJson(json['backgroundColor'] as String),
  );
}

Map<String, dynamic> _$CategoryIconConfigToJson(CategoryIconConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('category', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('image', instance.imageUrl);
  writeNotNull('colors', instance.colors);
  writeNotNull('backgroundColor', instance.backgroundColor);
  return val;
}
