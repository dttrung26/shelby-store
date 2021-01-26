import 'package:flutter/material.dart';

class PinCodeWidget extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final Function(String) onChanged;
  final double borderRadius;
  const PinCodeWidget(
      {Key key,
      @required this.controller,
      @required this.length,
      @required this.onChanged,
      this.borderRadius = 0.0})
      : super(key: key);

  @override
  _PinCodeWidgetState createState() => _PinCodeWidgetState();
}

class _PinCodeWidgetState extends State<PinCodeWidget> {
  List<FocusNode> listFocusNode = [];
  int currentIndex = 0;
  @override
  void initState() {
    List.generate(widget.length, (index) => listFocusNode.add(FocusNode()));

    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.text.length == widget.length &&
          currentIndex == widget.length - 1) {
        widget.onChanged(widget.controller.text);
      }
    });
    listFocusNode.first.requestFocus();
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Flexible(
          child: Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.only(left: 3.0, top: 7.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: listFocusNode[index].hasFocus
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: TextField(
                focusNode: listFocusNode[index],
                maxLength: 1,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5,
                onTap: () => setState(() => currentIndex = index),
                onSubmitted: (value) {
                  if (widget.controller.text.length == widget.length) {
                    widget.onChanged(widget.controller.text);
                  }
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    return;
                  }
                  if (index < widget.controller.text.length) {
                    widget.controller.text =
                        replaceCharAt(widget.controller.text, index, value);
                  } else {
                    widget.controller.text += value;
                  }

                  listFocusNode[index].unfocus();
                  if ((index + 1) < widget.length) {
                    currentIndex++;
                    listFocusNode[index + 1].requestFocus();
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  counter: Container(),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(1),
                ),
              )),
        );
      }),
    );
  }
}
