import 'package:flutter/material.dart';

import '../woocommerce/index.dart';
import 'screens/main_screen/main_screen.dart';

class VendorAdminWidget extends WooWidget {
  @override
  Widget renderVendorDashBoard() {
    return const VendorAdminMainScreen();
  }
}
