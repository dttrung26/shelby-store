import 'package:json_annotation/json_annotation.dart';
part 'currency.g.dart';

@JsonSerializable(nullable: false)
class Currency {
  final String symbol;

  final int decimalDigits;

  final bool symbolBeforeTheNumber;

  @JsonKey(name: 'currency')
  final String currencyDisplay;

  final String currencyCode;

  final int smallestUnitRate;

  Currency({
    this.symbol,
    this.decimalDigits,
    this.symbolBeforeTheNumber,
    this.currencyDisplay,
    this.currencyCode,
    this.smallestUnitRate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);
  Map<String, dynamic> toJson(instance) => _$CurrencyToJson(this);
}
