import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/entities/coupon.dart';
import '../../models/index.dart' show AppModel, UserModel;
import '../../services/index.dart';
import '../base.dart';

class CouponList extends StatefulWidget {
  final String couponCode;
  final Coupons coupons;
  final Function onSelect;
  final bool isFromCart;

  const CouponList({
    Key key,
    this.couponCode,
    this.coupons,
    this.onSelect,
    this.isFromCart = false,
  }) : super(key: key);

  @override
  _CouponListState createState() => _CouponListState();
}

class _CouponListState extends BaseScreen<CouponList> {
  final services = Services();
  final List<Coupon> _coupons = [];
  final TextEditingController _couponTextController = TextEditingController();

  List<Coupon> _newCoupons;
  String email;
  bool isFetching = false;

  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.couponCode != null) {
      setState(() {
        _couponTextController.text = widget.couponCode;
      });
    }

    email = Provider.of<UserModel>(context, listen: false).user?.email;
    _displayCoupons(context);

    /// Fetch new coupons.
    setState(() {
      isFetching = true;
    });
    services.api.getCoupons().then((coupons) {
      _newCoupons = coupons.coupons;
      setState(() {
        isFetching = false;
      });
      _displayCoupons(context);
    });
  }

  void _displayCoupons(BuildContext context) {
    _coupons.clear();
    _coupons.addAll(List.from(_newCoupons ?? widget.coupons?.coupons ?? []));

    final bool showAllCoupons = kAdvanceConfig['ShowAllCoupons'] ?? false;
    final bool showExpiredCoupons =
        kAdvanceConfig['ShowExpiredCoupons'] ?? false;

    final searchQuery = _couponTextController.text.toLowerCase();

    _coupons.retainWhere((c) {
      var shouldKeep = true;

      /// Hide expired coupons
      if (!showExpiredCoupons && c.dateExpires != null) {
        shouldKeep &= c.dateExpires.isAfter(DateTime.now());
      }

      /// Search for coupons using code & description
      /// Users can search for any coupons by entering
      /// any part of code or description when showAllCoupons is true.
      if (showAllCoupons && searchQuery.isNotEmpty) {
        shouldKeep &= ('${c.code}'.toLowerCase().contains(searchQuery) ||
            '${c?.description ?? ''}'.toLowerCase().contains(searchQuery));
      }

      /// Search for coupons using exact code.
      /// Users can search for hidden coupons by entering
      /// exact code when showAllCoupons is false.
      if (!showAllCoupons && searchQuery.isNotEmpty) {
        shouldKeep &= '${c.code}'.toLowerCase() == searchQuery;
      }

      /// Show only coupons which is restricted to user.
      if (!showAllCoupons && searchQuery.isEmpty) {
        shouldKeep &= c.emailRestrictions.contains(email);
      }

      /// Hide coupons which is restricted to other users.
      if (showAllCoupons &&
          searchQuery.isEmpty &&
          c.emailRestrictions.isNotEmpty) {
        shouldKeep &= c.emailRestrictions.contains(email);
      }

      return shouldKeep;
    });

    // _coupons.sort((a, b) => b.emailRestrictions.contains(email) ? 0 : -1);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkTheme ? theme.backgroundColor : theme.cardColor,
      appBar: AppBar(
        backgroundColor: isDarkTheme ? theme.backgroundColor : theme.cardColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 22,
          ),
        ),
        titleSpacing: 0.0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.only(left: 24),
          margin: const EdgeInsets.only(right: 24.0),
          child: TextField(
            onChanged: (_) {
              _displayCoupons(context);
            },
            controller: _couponTextController,
            decoration: InputDecoration(
              fillColor: Theme.of(context).accentColor,
              border: InputBorder.none,
              hintText: S.of(context).couponCode,
              focusColor: Theme.of(context).accentColor,
              suffixIcon: IconButton(
                onPressed: () {
                  _couponTextController.clear();
                  _displayCoupons(context);
                },
                icon: Icon(
                  Icons.cancel,
                  color: Theme.of(context).accentColor.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color:
                  isDarkTheme ? theme.backgroundColor : theme.primaryColorLight,
              child: (isFetching && (_coupons?.isEmpty ?? true))
                  ? kLoadingWidget(context)
                  : ListView.builder(
                      itemCount: _coupons?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        final coupon = _coupons[index];
                        if (coupon == null || coupon?.code == null) {
                          return const SizedBox();
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 8.0,
                          ),
                          child: CouponItem(
                            coupon: coupon,
                            onSelect: widget.onSelect,
                            email: email,
                            isFromCart: widget.isFromCart,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class CouponItem extends StatelessWidget {
  final Coupon coupon;
  final Function onSelect;
  final String email;
  final bool isFromCart;

  static const double _iconSize = 65.0;
  static const double _iconPadding = 24.0;

  static const _couponClipper = CouponClipper(
    borderRadius: 5.0,
    smallClipRadius: 4.0,
    numberOfSmallClips: 8,
  );

  const CouponItem({
    Key key,
    this.coupon,
    this.onSelect,
    this.email,
    this.isFromCart = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = _getCouponCount(coupon, email);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final _content = Container(
      color: isDarkTheme
          ? Theme.of(context).cardColor
          : Theme.of(context).backgroundColor,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _iconPadding),
            child: CouponIcon(
              coupon: coupon,
              size: _iconSize,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Container(
                      decoration: count.isNotEmpty
                          ? BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(9.0),
                                bottomRight: Radius.circular(9.0),
                              ),
                            )
                          : null,
                      margin: const EdgeInsets.only(right: 18.0),
                      padding: const EdgeInsets.only(
                        top: 6.0,
                        left: 8.0,
                        bottom: 6.0,
                        right: 8.0,
                      ),
                      child: Text(
                        count,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getCouponTitle(context, coupon),
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 16),
                  child: Text(
                    _getCouponDescription(context, coupon),
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    ..._getCouponExpireDateWidget(context, coupon),
                    if (coupon.isExpired)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          S.of(context).expired,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () {
                          if (onSelect != null) {
                            onSelect(coupon.code);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          isFromCart
                              ? S.of(context).useNow
                              : S.of(context).saveForLater,
                        ),
                      ),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return LayoutBuilder(builder: (context, constraint) {
      return Stack(
        children: [
          if (count.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(top: 4.0),
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              child: CustomPaint(
                painter: CouponPainter(
                  shadow: const Shadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 2.0,
                  ),
                  clipper: _couponClipper,
                ),
                child: ClipPath(
                  clipper: _couponClipper,
                  child: _content,
                ),
              ),
            ),
          Container(
            padding:
                count.isNotEmpty ? const EdgeInsets.only(bottom: 4.0) : null,
            child: CustomPaint(
              painter: CouponPainter(
                shadow: Shadow(
                  color: Colors.black12,
                  offset: Offset(0, count.isNotEmpty ? 4 : 2),
                  blurRadius: count.isNotEmpty ? 4.0 : 2.0,
                ),
                clipper: _couponClipper,
              ),
              child: ClipPath(
                clipper: _couponClipper,
                child: _content,
              ),
            ),
          ),
        ],
      );
    });
  }

  String _getCouponCount(Coupon coupon, String email) {
    int usageLimit;
    int usageCount;

    if (email != null &&
        email.isNotEmpty &&
        coupon.usageLimitPerUser != null &&
        coupon.usedBy != null) {
      final usedByUser = List.castFrom(coupon.usedBy);
      usedByUser.retainWhere((item) => item == email);
      usageLimit = coupon.usageLimitPerUser;
      usageCount = usedByUser.length;
    } else {
      usageLimit = coupon.usageLimit;
      usageCount = coupon.usageCount;
    }

    if (usageLimit != null &&
        usageCount != null &&
        (usageLimit - usageCount > 1)) {
      return 'x${usageLimit - usageCount}';
    }
    return '';
  }

  String _getCouponDescription(BuildContext context, Coupon coupon) {
    if (coupon.description != null && '${coupon.description}'.isNotEmpty) {
      return '${coupon.description}';
    }
    return '';
  }

  List<Widget> _getCouponExpireDateWidget(BuildContext context, Coupon coupon) {
    final locale = Provider.of<AppModel>(context).langCode ?? 'en';
    final now = DateTime.now();
    final expiringSoon = coupon.dateExpires != null &&
        !coupon.dateExpires.isAfter(now.add(const Duration(days: 3))) &&
        !coupon.isExpired;

    var title = '';

    if (coupon.dateExpires != null) {
      title = S
          .of(context)
          .validUntilDate(DateFormat('yyyy-MM-dd').format(coupon.dateExpires));
    }

    if (expiringSoon) {
      final timeDif = now.difference(coupon.dateExpires);
      title = S.of(context).expiringInTime(
            timeago.format(
              now.subtract(timeDif),
              locale: locale,
              allowFromNow: true,
            ),
          );
    }

    return [
      if (expiringSoon)
        const Padding(
          padding: EdgeInsets.only(right: 2.0),
          child: Icon(
            Icons.access_time_sharp,
            color: Colors.red,
            size: 11,
          ),
        ),
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            color:
                (expiringSoon || coupon.isExpired) ? Colors.red : Colors.grey,
            fontSize: 11,
            fontWeight: expiringSoon ? FontWeight.bold : FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }

  String _getCouponTitle(BuildContext context, Coupon coupon) {
    return '${_getCouponAmount(context, coupon)} ${_getCouponTypeTitle(context, coupon)}';
  }
}

class CouponIcon extends StatelessWidget {
  final Coupon coupon;
  final double size;

  const CouponIcon({Key key, this.coupon, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size * 1.1,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getCouponTypeTitle(context, coupon).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 7,
                      letterSpacing: 1.1,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getCouponAmount(context, coupon),
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 2, top: 1),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Text(
                      '${coupon.code}'.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 7,
                        letterSpacing: 0.7,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _getCouponTypeTitle(BuildContext context, Coupon coupon) {
  if (coupon.isPercentageDiscount) {
    return S.of(context).discount;
  }
  if (coupon.isFixedCartDiscount) {
    return S.of(context).fixedCartDiscount;
  }
  if (coupon.isFixedProductDiscount) {
    return S.of(context).fixedProductDiscount;
  }
  return '${coupon.code}'.toUpperCase();
}

String _getCouponAmount(BuildContext context, Coupon coupon) {
  if (coupon.isPercentageDiscount) {
    return '${coupon.amount}%';
  }
  if (coupon.isFixedCartDiscount || coupon.isFixedProductDiscount) {
    final model = Provider.of<AppModel>(context);
    return '${Tools.getCurrencyFormatted(
      coupon.amount,
      model.currencyRate,
      currency: model.currency,
    )}';
  }
  return '${coupon.amount}'.toUpperCase();
}

class CouponPainter extends CustomPainter {
  final Shadow shadow;
  final CustomClipper<Path> clipper;

  CouponPainter({this.shadow, this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CouponClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double smallClipRadius;
  final int numberOfSmallClips;

  const CouponClipper({
    this.borderRadius,
    this.smallClipRadius,
    this.numberOfSmallClips,
  });

  @override
  Path getClip(Size size) {
    var path = Path();

    // draw rect
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    ));

    // draw small clip circles
    final clipContainerSize = size.height - smallClipRadius;
    final smallClipSize = smallClipRadius * 2;
    final smallClipBoxSize = clipContainerSize / numberOfSmallClips;
    final smallClipPadding = (smallClipBoxSize - smallClipSize) / 2;
    final smallClipStart = smallClipRadius / 2;

    final clipPath = Path();

    final smallClipCenterOffsets = List.generate(numberOfSmallClips, (index) {
      final boxX = smallClipStart + smallClipBoxSize * index;
      final centerX = boxX + smallClipPadding + smallClipRadius;

      return Offset(0, centerX);
    });

    smallClipCenterOffsets.forEach((centerOffset) {
      clipPath.addOval(Rect.fromCircle(
        center: centerOffset,
        radius: smallClipRadius,
      ));
    });

    // combine two path together
    final ticketPath = Path.combine(
      PathOperation.reverseDifference,
      clipPath,
      path,
    );

    return ticketPath;
  }

  @override
  bool shouldReclip(CouponClipper old) =>
      old.borderRadius != borderRadius ||
      old.smallClipRadius != smallClipRadius ||
      old.numberOfSmallClips != numberOfSmallClips ||
      true;
}
