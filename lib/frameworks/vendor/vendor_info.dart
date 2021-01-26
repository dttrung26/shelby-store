import 'package:flutter/material.dart';

import '../../models/index.dart' show Product;
import 'store/store_item.dart';

class VendorInfo extends StatefulWidget {
  final Product product;

  VendorInfo(this.product);
  @override
  _VendorInfoState createState() => _VendorInfoState();
}

class _VendorInfoState extends State<VendorInfo> {
  @override
  Widget build(BuildContext context) {
    if (widget.product.store == null) return Container();

    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        StoreItem(store: widget.product.store),
      ],
    );
  }
}
