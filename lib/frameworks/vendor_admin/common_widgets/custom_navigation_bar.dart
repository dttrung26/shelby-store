import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final Function(int) onTap;
  final List<CustomNavBar> tabs;
  final int currentIndex;
  final Color selectedColor;
  final Color unSelectedColor;
  const CustomNavigationBar({
    Key key,
    @required this.onTap,
    @required this.tabs,
    this.currentIndex = 0,
    this.selectedColor,
    this.unSelectedColor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: Container(
        height: 44,
        width: size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 4,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            tabs.length,
            (index) => InkWell(
              onTap: () => onTap(index),
              child: Container(
                width: size.width / tabs.length,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index].icon,
                      color: currentIndex == index
                          ? selectedColor ??
                              Theme.of(context).accentIconTheme.color
                          : unSelectedColor ??
                              Theme.of(context).primaryIconTheme.color,
                    ),
                    Text(
                      tabs[index].title,
                      style: TextStyle(
                        fontSize: 11,
                        color: currentIndex == index
                            ? selectedColor ??
                                Theme.of(context).accentIconTheme.color
                            : unSelectedColor ??
                                Theme.of(context).primaryIconTheme.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomNavBar {
  IconData icon;
  String title;

  CustomNavBar({@required this.icon, @required this.title});
}
