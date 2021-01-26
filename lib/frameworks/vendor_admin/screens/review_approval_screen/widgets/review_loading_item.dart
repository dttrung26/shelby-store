import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../widgets/common/skeleton.dart';

class VendorAdminReviewLoadingItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
      height: 240,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey.withOpacity(0.5))),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Skeleton(
                  height: 14,
                  width: 100,
                ),
              ),
              Expanded(
                  child: Row(
                children: [
                  const Expanded(
                      child: SizedBox(
                    width: 1,
                  )),
                  const Skeleton(
                    height: 10,
                    width: 100,
                  ),
                ],
              ))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Center(
                    child: Skeleton(
                      height: 30,
                      width: 30,
                      cornerRadius: 30.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Skeleton(
                      height: 12,
                      width: 150,
                    ),
                    const SizedBox(height: 5.0),
                    const Skeleton(
                      height: 12,
                      width: 80,
                    ),
                    const SizedBox(height: 5.0),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            width: size.width,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Expanded(
                child: Skeleton(
                  height: 12,
                  width: 50,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(child: SizedBox(width: 10)),
                    const Skeleton(
                      height: 30,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: size.width,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: SizedBox(
                  width: 1,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                child: const Center(
                  child: Skeleton(
                    height: 12,
                    width: 60,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
