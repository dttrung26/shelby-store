import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import 'sub_screens/approved_review_screen.dart';
import 'sub_screens/pending_review_screen.dart';

class VendorAdminReviewApprovalScreen extends StatefulWidget {
  @override
  _VendorAdminReviewApprovalScreenState createState() =>
      _VendorAdminReviewApprovalScreenState();
}

class _VendorAdminReviewApprovalScreenState
    extends State<VendorAdminReviewApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(
            S.of(context).reviewApproval,
            style: Theme.of(context).primaryTextTheme.headline5,
          ),
          brightness: Theme.of(context).brightness,
          centerTitle: true,
//          actions: [
//            const Icon(Icons.menu),
//            const SizedBox(width: 20),
//          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: S.of(context).approved,
              ),
              Tab(
                text: S.of(context).pending,
              ),
            ],
          ),
        ),
        body: Container(
          width: size.width,
          height: size.height,
          color: Theme.of(context).backgroundColor,
          child: TabBarView(
            children: [
              ApprovedReviewScreen(),
              PendingReviewScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
