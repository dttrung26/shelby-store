import 'package:flutter/material.dart';

class FilterOptionItem extends StatelessWidget {
  final bool enabled;
  final Function onTap;
  final bool selected;
  final String title;
  final bool isValid;

  const FilterOptionItem({
    Key key,
    this.enabled = true,
    this.onTap,
    this.selected,
    this.title,
    this.isValid = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (enabled == true && onTap != null) {
          onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(5.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13.0,
            vertical: 20.0,
          ),
          child: Text(
            title ?? '',
            style: isValid == true
                ? selected == true
                    ? TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontSize: 15,
                      )
                    : TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontSize: 15,
                      )
                : TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ),
        decoration: BoxDecoration(
          color: isValid == true
              ? selected == true
                  ? Theme.of(context).backgroundColor
                  : Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            if (selected == true)
              const BoxShadow(
                color: Colors.white12,
                blurRadius: 15,
              ),
          ],
        ),
        constraints: const BoxConstraints(minWidth: 100),
      ),
    );
  }
}
