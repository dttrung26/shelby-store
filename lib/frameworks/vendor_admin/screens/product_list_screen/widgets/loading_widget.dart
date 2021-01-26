import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../widgets/common/skeleton.dart';

class VendorAdminProductListCardLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Skeleton(
              height: 100,
              width: 100,
              cornerRadius: 10.0,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 5.0),
                  Skeleton(
                    width: Random().nextInt(200) + 100.0,
                    height: 20,
                  ),
                  const SizedBox(height: 10),
                  const Skeleton(
                    width: 80,
                    height: 20,
                  ),
                  const SizedBox(height: 35),
                  Row(
                    children: [
                      const Skeleton(
                        width: 30,
                        height: 16,
                      ),
                      const SizedBox(width: 110),
                      const Flexible(
                        child: Skeleton(
                          width: 80.0,
                          height: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
