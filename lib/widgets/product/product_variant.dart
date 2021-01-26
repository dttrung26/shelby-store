import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';

enum VariantLayout { inline, dropdown }

class BasicSelection extends StatelessWidget {
  final Map<String, String> imageUrls;
  final List<String> options;
  final String value;
  final String title;
  final String type;
  final Function onChanged;
  final VariantLayout layout;

  BasicSelection(
      {@required this.options,
      @required this.title,
      @required this.value,
      this.type,
      this.layout,
      this.onChanged,
      this.imageUrls});

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;

    if (type == 'option') {
      return OptionSelection(
        options: options,
        value: value,
        title: title,
        onChanged: onChanged,
      );
    }

    if (type == 'image') {
      return ImageSelection(
        imageUrls: imageUrls,
        options: options,
        value: value,
        title: title,
        onChanged: onChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                child: Text(
                  // ignore: prefer_single_quotes
                  "${title[0].toUpperCase()}${title.substring(1)}",
                  style: Theme.of(context).textTheme.headline6,
                ),
                padding: const EdgeInsets.only(bottom: 2),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 0.0,
          runSpacing: 12.0,
          children: <Widget>[
            for (var item in options)
              GestureDetector(
                onTap: () => onChanged(item),
                behavior: HitTestBehavior.opaque,
                child: Tooltip(
                  message: item.toString(),
                  verticalOffset: 32,
                  preferBelow: false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    margin: const EdgeInsets.only(
                      right: 12.0,
                      top: 8.0,
                    ),
                    decoration: type == 'color'
                        ? BoxDecoration(
                            color: item.toUpperCase() == value.toUpperCase()
                                ? HexColor(kNameToHex[item
                                        .toString()
                                        .replaceAll(' ', '_')
                                        .toLowerCase()] ??
                                    '#ffffff')
                                : HexColor(kNameToHex[item
                                            .toString()
                                            .replaceAll(' ', '_')
                                            .toLowerCase()] ??
                                        '#ffffff')
                                    .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              width: 1.0,
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.3),
                            ),
                          )
                        : BoxDecoration(
                            color: item.toUpperCase() == value.toUpperCase()
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.3),
                            ),
                          ),
                    child: type == 'color'
                        ? SizedBox(
                            height: 25,
                            width: 25,
                            child: item == value
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : const SizedBox(),
                          )
                        : Container(
                            constraints: const BoxConstraints(minWidth: 40),
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Padding(
                              child: Text(
                                item,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: item == value
                                      ? Colors.white
                                      : Theme.of(context).accentColor,
                                  fontSize: 14,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                            ),
                          ),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}

class OptionSelection extends StatelessWidget {
  final List<String> options;
  final String value;
  final String title;
  final Function onChanged;
  final VariantLayout layout;

  OptionSelection({
    @required this.options,
    @required this.value,
    this.title,
    this.layout,
    this.onChanged,
  });

  // ignore: always_declare_return_types
  showOptions(context) {
    showModalBottomSheet(
      context: context,
      // https://github.com/inspireui/support/issues/4814#issuecomment-684179116
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final option in options)
                ListTile(
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(context);
                    },
                    title: Text(option, textAlign: TextAlign.center)),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).selectTheSize,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showOptions(context),
      child: Container(
        height: 42,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  // ignore: prefer_single_quotes
                  "${title[0].toUpperCase()}${title.substring(1)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
            ],
          ),
        ),
      ),
    );
  }
}

class ColorSelection extends StatelessWidget {
  final List<String> options;
  final String value;
  final Function onChanged;
  final VariantLayout layout;

  ColorSelection(
      {@required this.options,
      @required this.value,
      this.layout,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (layout == VariantLayout.dropdown) {
      return GestureDetector(
        onTap: () => showOptions(context),
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(width: 1.0, color: kGrey200)),
          height: 42,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(S.of(context).color,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: kNameToHex[value.toLowerCase()] != null
                            ? HexColor(kNameToHex[value.toLowerCase()])
                            : Colors.transparent)),
                const SizedBox(width: 5),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 25,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Center(
              child: Text(
                S.of(context).color,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 15.0),
            for (var item in options)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                margin: const EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                  color: item == value
                      ? HexColor(kNameToHex[item.toLowerCase()])
                      : HexColor(kNameToHex[item.toLowerCase()])
                          .withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                      width: 1.0,
                      color: Theme.of(context).accentColor.withOpacity(0.5)),
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    onChanged(item);
                  },
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: item == value
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Container(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final option in options)
                ListTile(
                  onTap: () {
                    onChanged(option);
                    Navigator.pop(context);
                  },
                  title: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(
                            width: 1.0, color: Theme.of(context).accentColor),
                        color: HexColor(kNameToHex[option.toLowerCase()]),
                      ),
                    ),
                  ),
                ),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).selectTheColor,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuantitySelection extends StatefulWidget {
  final int limitSelectQuantity;
  final int value;
  final double width;
  final double height;
  final Function onChanged;
  final Color color;
  final bool useNewDesign;
  final bool enabled;
  final bool expanded;

  QuantitySelection({
    @required this.value,
    this.width = 40.0,
    this.height = 42.0,
    this.limitSelectQuantity = 100,
    @required this.color,
    this.onChanged,
    this.useNewDesign = true,
    this.enabled = true,
    this.expanded = false,
  });

  @override
  _QuantitySelectionState createState() => _QuantitySelectionState();
}

class _QuantitySelectionState extends State<QuantitySelection> {
  final TextEditingController _textController = TextEditingController();
  Timer _debounce;

  Timer _changeQuantityTimer;

  @override
  void initState() {
    super.initState();
    _textController.text = '${widget.value}';
    _textController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _textController?.removeListener(_onQuantityChanged);
    _changeQuantityTimer?.cancel();
    _debounce?.cancel();
    _textController?.dispose();
    super.dispose();
  }

  int get currentQuantity => int.tryParse(_textController.text) ?? -1;

  bool _validateQuantity([int value]) {
    if ((value ?? currentQuantity) <= 0) {
      _textController.text = '1';
      return false;
    }

    if ((value ?? currentQuantity) > widget.limitSelectQuantity) {
      _textController.text = '${widget.limitSelectQuantity}';
      return false;
    }
    return true;
  }

  void changeQuantity(int value, {bool forceUpdate = false}) {
    if (!_validateQuantity(value)) {
      return;
    }

    if (value != currentQuantity || forceUpdate == true) {
      _textController.text = '$value';
    }
  }

  void _onQuantityChanged() {
    if (!_validateQuantity()) {
      return;
    }

    if (_debounce?.isActive ?? false) {
      _debounce.cancel();
    }
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () {
        if (widget.onChanged != null) {
          widget.onChanged(currentQuantity);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useNewDesign == true) {
      final _iconPadding = EdgeInsets.all(
        max(
          ((widget.height ?? 32.0) - 24.0 - 8) * 0.5,
          0.0,
        ),
      );
      final _textField = Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: widget.height,
        width: widget.expanded == true ? null : widget.width,
        decoration: BoxDecoration(
          border: Border.all(width: 1.0, color: kGrey200),
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
        child: TextField(
          readOnly: widget.enabled == false,
          enabled: widget.enabled == true,
          controller: _textController,
          maxLines: 1,
          maxLength: '${widget.limitSelectQuantity ?? 100}'.length,
          onEditingComplete: _validateQuantity,
          onSubmitted: (_) => _validateQuantity(),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: false,
          ),
          textAlign: TextAlign.center,
        ),
      );
      return Row(
        children: [
          widget.enabled == true
              ? IconButton(
                  padding: _iconPadding,
                  onPressed: () => changeQuantity(currentQuantity - 1),
                  icon: const Center(
                      child: Icon(
                    Icons.arrow_back_ios,
                    size: 15,
                  )),
                )
              : const SizedBox.shrink(),
          widget.expanded == true
              ? Expanded(
                  child: _textField,
                )
              : _textField,
          widget.enabled == true
              ? IconButton(
                  padding: _iconPadding,
                  onPressed: () => changeQuantity(currentQuantity + 1),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      );
    }
    return GestureDetector(
      onTap: () {
        if (widget.onChanged != null) {
          showOptions(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1.0, color: kGrey200),
          borderRadius: BorderRadius.circular(3),
        ),
        height: widget.height,
        width: widget.width,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: (widget.onChanged != null) ? 5.0 : 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text(
                    widget.value.toString(),
                    style: TextStyle(fontSize: 14, color: widget.color),
                  ),
                ),
              ),
              if (widget.onChanged != null)
                const SizedBox(
                  width: 5.0,
                ),
              if (widget.onChanged != null)
                Icon(Icons.keyboard_arrow_down,
                    size: 14, color: Theme.of(context).accentColor)
            ],
          ),
        ),
      ),
    );
  }

  void showOptions(context) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int option = 1;
                          option <= widget.limitSelectQuantity;
                          option++)
                        ListTile(
                            onTap: () {
                              widget.onChanged(option);
                              Navigator.pop(context);
                            },
                            title: Text(
                              option.toString(),
                              textAlign: TextAlign.center,
                            )),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).selectTheQuantity,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }
}

class ImageSelection extends StatelessWidget {
  final Map<String, String> imageUrls;
  final List<String> options;
  final String value;
  final String title;
  final Function onChanged;
  final VariantLayout layout;

  ImageSelection({
    @required this.options,
    @required this.value,
    this.title,
    this.layout,
    this.onChanged,
    this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    final double size = kProductDetail['attributeImagesSize'] ?? 50.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                child: Text(
                  // ignore: prefer_single_quotes
                  "${title[0].toUpperCase()}${title.substring(1)}",
                  style: Theme.of(context).textTheme.headline6,
                ),
                padding: const EdgeInsets.only(bottom: 10),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 0.0,
          runSpacing: 12.0,
          children: <Widget>[
            for (var item in options)
              GestureDetector(
                onTap: () => onChanged(item),
                child: Tooltip(
                  message: HtmlUnescape().convert(item),
                  preferBelow: false,
                  verticalOffset: 32,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Container(
                      width: size + 2,
                      height: size + 2,
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          width: 1.0,
                          color: Theme.of(context).accentColor.withOpacity(
                              item.toUpperCase() == value.toUpperCase()
                                  ? 0.6
                                  : 0.3),
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (imageUrls[item]?.isNotEmpty ?? false)
                            Positioned.fill(
                              child: Tools.image(
                                url: imageUrls[item],
                                height: size,
                                width: size,
                              ),
                            )
                          else
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  HtmlUnescape().convert(item),
                                ),
                              ),
                            ),
                          if (item.toUpperCase() == value.toUpperCase())
                            Positioned.fill(
                              child: Container(
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.6),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}
