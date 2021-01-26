import 'package:flutter/material.dart';

class SelectInfo extends StatelessWidget {
  final String title;
  final String hint;
  final String valueSelected;
  final List<String> data;
  final Function(String) onChanged;

  SelectInfo({
    Key key,
    this.valueSelected,
    this.data,
    this.onChanged,
    this.title,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
        DropdownButton(
          hint: Text('${hint ?? "Choose item"}'),
          value: valueSelected,
          underline: Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down_circle),
          items: List.generate(
            data.length ?? 0,
            (indexs) {
              return DropdownMenuItem(
                value: data[indexs],
                child: Container(
                  constraints: const BoxConstraints(minWidth: 140),
                  child: Text(
                    data[indexs],
                  ),
                ),
              );
            },
          ),
          onChanged: onChanged,
        )
      ],
    );
  }
}
