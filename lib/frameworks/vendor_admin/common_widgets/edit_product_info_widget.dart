import 'package:flutter/material.dart';

class EditProductInfoWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isMultiline;
  final bool isObscure;
  final Widget prefixIcon;
  final double fontSize;
  final TextInputType keyboardType;
  const EditProductInfoWidget({
    Key key,
    @required this.controller,
    @required this.label,
    this.isMultiline = false,
    this.prefixIcon,
    this.fontSize,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 15,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(9.0),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).accentColor.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(9.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              fillColor: Theme.of(context).primaryColorLight,
              filled: true,
              prefixIcon: prefixIcon,
            ),
            obscureText: isObscure,
            maxLines: isMultiline ? 7 : 1,
            keyboardType: keyboardType,
          ),
        ),
      ],
    );
  }
}
