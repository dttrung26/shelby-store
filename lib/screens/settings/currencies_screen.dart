import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../../models/serializers/currency.dart';
import '../../screens/base.dart';

class CurrenciesScreen extends StatefulWidget {
  @override
  _CurrenciesScreenState createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends BaseScreen<CurrenciesScreen> {
  String currencyDisplay;

  @override
  void afterFirstLayout(BuildContext context) {
    currencyDisplay = Provider.of<AppModel>(context, listen: false).currency;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List data = kAdvanceConfig['Currencies'] ?? [];
    final currencies = data.map((e) => Currency.fromJson(e)).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).currencies,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: Center(
          child: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: currencies.length,
        separatorBuilder: (_, __) => const Divider(
          color: Colors.black12,
          height: 1.0,
          indent: 75,
          //endIndent: 20,
        ),
        itemBuilder: (_, index) => buildItem(currencies[index]),
      ),
    );
  }

  Widget buildItem(Currency currency) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      child: ListTile(
        title: Text('${currency.currencyDisplay} (${currency.symbol})'),
        onTap: () {
          setState(() {
            currencyDisplay = currency.currencyDisplay;
          });

          Provider.of<AppModel>(context, listen: false).changeCurrency(
            currency.currencyDisplay,
            context,
            code: currency.currencyCode,
          );
        },
        trailing: currencyDisplay == currency.currencyDisplay
            ? const Icon(Icons.done)
            : Container(
                width: 20,
              ),
      ),
    );
  }
}
