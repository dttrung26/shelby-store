import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../widgets/common/skeleton.dart';

class VendorAdminNotificationLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildNotificationIcon() => CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black38.withOpacity(0.3),
          child: const Skeleton(
            width: 40,
            height: 40,
            cornerRadius: 50,
          ),
        );

    Widget _buildMessageTypeText() {
      return Skeleton(
        height: 12,
        width: Random().nextInt(100) + 100.0,
      );
    }

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      padding: const EdgeInsets.all(
        10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildNotificationIcon(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(
                  height: 10,
                  width: Random().nextInt(100) + 100.0,
                ),
                const SizedBox(height: 3),
                Skeleton(
                  height: 16,
                  width: Random().nextInt(200) + 100.0,
                ),
                const SizedBox(height: 5),
                _buildMessageTypeText(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
