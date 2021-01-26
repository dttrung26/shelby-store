import 'package:flutter/material.dart';

class VendorAdminSettingItem extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final IconData actionIcon;
  final bool isSwitchedOn;
  final Function onTap;

  const VendorAdminSettingItem(
      {Key key,
      @required this.leadingIcon,
      @required this.title,
      this.actionIcon,
      this.isSwitchedOn,
      @required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.only(
          bottom: 20,
        ),
        child: Row(
          children: [
            Icon(
              leadingIcon,
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: Theme.of(context).primaryTextTheme.subtitle1,
            ),
            const Expanded(
                child: SizedBox(
              width: 1,
            )),
            if (actionIcon == null && isSwitchedOn == null) Container(),
            if (actionIcon != null && isSwitchedOn == null) Icon(actionIcon),
            if (actionIcon == null && isSwitchedOn != null)
              Switch(
                value: isSwitchedOn,
                onChanged: (val) => onTap(),
                activeColor: Theme.of(context).accentIconTheme.color,
              ),
          ],
        ),
      ),
    );
  }
}
