import 'package:flutter/material.dart';

class PaymentMethodWidget extends StatelessWidget {
  final bool isSelect;
  final String title;
  final Image image;

  const PaymentMethodWidget(
      {Key key, @required this.isSelect, this.image, @required this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: isSelect
            ? Theme.of(context).primaryColor
            : Theme.of(context).accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(9.0),
      ),
      height: 110,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null) image,
          if (image == null)
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  )
                  .apply(fontSizeFactor: 1.5),
            )
        ],
      ),
    );
  }
}
