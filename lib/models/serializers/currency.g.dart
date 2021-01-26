// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Currency _$CurrencyFromJson(Map<String, dynamic> json) {
  return Currency(
    symbol: json['symbol'] as String,
    decimalDigits: json['decimalDigits'] as int,
    symbolBeforeTheNumber: json['symbolBeforeTheNumber'] as bool,
    currencyDisplay: json['currency'] as String,
    currencyCode: json['currencyCode'] as String,
    smallestUnitRate: json['smallestUnitRate'] as int,
  );
}

Map<String, dynamic> _$CurrencyToJson(Currency instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'decimalDigits': instance.decimalDigits,
      'symbolBeforeTheNumber': instance.symbolBeforeTheNumber,
      'currency': instance.currencyDisplay,
      'currencyCode': instance.currencyCode,
      'smallestUnitRate': instance.smallestUnitRate,
    };
