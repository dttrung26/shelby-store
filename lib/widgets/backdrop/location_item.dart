import 'package:flutter/material.dart';
import '../../models/entities/listing_location.dart';

class LocationItem extends StatelessWidget {
  final ListingLocation location;
  final bool isSelected;
  final Function onTap;

  LocationItem(
    this.location, {
    this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.check,
              color: isSelected ? Colors.white : Colors.transparent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                location.name,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(width: 20)
          ],
        ),
      ),
    );
  }
}
