import 'dart:math';

import 'package:flutter/material.dart';

import 'dropdown_constants.dart';

enum DropDownExpandType {
  down,
  up,
  center,
}

class DropDownWidgetItem {
  final Key key;
  final String id;
  final String value;
  DropDownWidgetItem({
    this.key,
    this.id,
    @required this.value,
  });
  @override
  String toString() {
    return '$id | $value';
  }
}

class DropDownWidget extends StatefulWidget {
  static BuildContext buildContext;
  final Function(DropDownWidgetItem item, int indexSelected) onChanged;
  final int indexSelected;
  final List<DropDownWidgetItem> data;
  final double width;
  final double height;
  final DropDownExpandType dropDownExpandType;
  final int countItemExpandList;
  final String label;
  final TextStyle labelStyle;
  final bool showLabelInList;
  final String labelValueDefault;
  final Color backgroundColor;
  final Color backgroundListColor;
  final Color borderColor;
  final bool forceChangeIndex;

  DropDownWidget({
    Key key,
    this.width,
    @required this.data,
    this.onChanged,
    this.indexSelected,
    this.dropDownExpandType = DropDownExpandType.down,
    this.height = 49,
    this.countItemExpandList = DropDownWidgetConstants.countItemExpandDefault,
    this.label,
    this.labelStyle,
    this.showLabelInList = false,
    this.labelValueDefault,
    this.backgroundColor = Colors.white,
    this.backgroundListColor = Colors.white,
    this.borderColor,
    this.forceChangeIndex = false,
  })  : assert(
          data.isNotEmpty,
          'A non-null data must be provided to a list widget.',
        ),
        super(key: key);

  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  int _indexSelected;
  ScrollController _scrollController;
  OverlayEntry _overlayEntry;
  bool _isShowList;
  bool _noneChoose;
  GlobalKey<_DropDownWidgetState> _globalKey;

  @override
  void initState() {
    _indexSelected = widget.indexSelected ?? 0;
    _isShowList = false;
    _scrollController = ScrollController();
    _noneChoose = true;
    _globalKey = GlobalKey<_DropDownWidgetState>();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _onTapDropDown() {
    setState(_show);
    _noneChoose = false;
  }

  @override
  void didUpdateWidget(DropDownWidget oldWidget) {
    if (oldWidget.indexSelected != widget.indexSelected ||
        oldWidget.data.length != widget.data.length ||
        widget.forceChangeIndex) {
      setState(() {
        _indexSelected = widget.indexSelected;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _globalKey,
      children: <Widget>[
        _buildButton(),
        _buildArrow(),
      ],
    );
  }

  OverlayEntry _buildEntry() {
    final RenderBox box = _globalKey.currentContext.findRenderObject();
    final pos = box.localToGlobal(Offset.zero);

    var top = pos.dy;
    switch (widget.dropDownExpandType) {
      case DropDownExpandType.down:
        break;
      case DropDownExpandType.up:
        top += -_getHeightList + widget.height;
        break;
      case DropDownExpandType.center:
        top -= _getHeightList / 2 - widget.height / 2;
        break;
    }

    return OverlayEntry(builder: (BuildContext context) {
      return Stack(
        children: <Widget>[
          GestureDetector(
            onTap: _hide,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: top,
            left: pos.dx,
            child: Stack(
              children: <Widget>[
                _buildList(),
                _buildArrow(isDown: true, type: widget.dropDownExpandType),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _show() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isShowList = true;
      _overlayEntry = _buildEntry();
      Overlay.of(DropDownWidget.buildContext ?? context).insert(_overlayEntry);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final center = widget.countItemExpandList ~/ 2;
        if (widget.data.length != widget.countItemExpandList &&
            _indexSelected > center) {
          _scrollController.animateTo(
            (_indexSelected - center) * widget.height,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 10),
          );
        }
      });
    });
  }

  void _hide() {
    _isShowList = false;
    _overlayEntry?.remove();
  }

  Widget _buildButton() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: _boderRadius,
        border: Border.all(
          width: DropDownWidgetConstants.borderWidth,
          color: Colors.transparent,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: _buildItem(_indexSelected, isDropdownButton: true),
    );
  }

  Widget _buildItem(int index, {bool isDropdownButton = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: widget?.data[index]?.key ??
            ValueKey('${DropDownWidgetKeys.item}$index'),
        onTap: () {
          if (_isShowList) {
            _hide();
            setState(() {
              _indexSelected = index;
            });
          } else {
            _show();
          }
          _noneChoose = false;
          if (!isDropdownButton) {
            widget?.onChanged?.call(widget.data[index], index);
          }
        },
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.only(
              left: DropDownWidgetConstants.arrowPaddingTop),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (!_isShowList && widget.label != null)
                  Text(
                    widget.label ?? '',
                    key: const ValueKey('dropdown_label'),
                    maxLines: 1,
                    style: widget.labelStyle ??
                        Theme.of(context).textTheme.overline.copyWith(
                              color: Colors.black.withOpacity(0.4),
                            ),
                  ),
                Text(
                  widget.showLabelInList && _noneChoose
                      ? widget.labelValueDefault
                      : widget.data[index].value,
                  key: ValueKey('dropdown_text_$index'),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.normal,
                        color: _getColorText(index),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorText(int index) {
    if (widget.showLabelInList) {
      return Colors.black;
    }
    return _indexSelected != index || !_isShowList
        ? Colors.black
        : Theme.of(context).primaryColor;
  }

  Widget _buildListItems() {
    // ignore: omit_local_variable_types
    final List<Widget> widgets = [];
    for (var i = 0; i < widget.data.length; i++) {
      widgets.add(_buildItem(i));
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: widgets,
    );
  }

  Widget _buildArrow({bool isDown = false, DropDownExpandType type}) {
    final arrow = Material(
      color: Colors.transparent,
      child: GestureDetector(
        key: DropDownWidgetKeys.arrow,
        onTap: isDown ? _hide : _onTapDropDown,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: _getColorBackground,
                blurRadius: 6.0,
                spreadRadius: 6.0,
              )
            ],
          ),
          child: Container(
            child: isDown
                ? const Icon(Icons.keyboard_arrow_up)
                : const Icon(Icons.keyboard_arrow_down),
          ),
        ),
      ),
    );
    switch (type) {
      case DropDownExpandType.down:
        return Positioned(
          right: DropDownWidgetConstants.arrowPaddingRight,
          top: DropDownWidgetConstants.arrowPaddingTop,
          child: arrow,
        );
      case DropDownExpandType.up:
        return Positioned(
          right: DropDownWidgetConstants.arrowPaddingRight,
          bottom: DropDownWidgetConstants.arrowPaddingTop,
          child: arrow,
        );
      case DropDownExpandType.center:
        return Positioned(
          right: DropDownWidgetConstants.arrowPaddingRight,
          bottom: _getHeightList / 2 - DropDownWidgetConstants.arrowPaddingTop,
          child: arrow,
        );
    }
    return Positioned(
      right: DropDownWidgetConstants.arrowPaddingRight,
      bottom: DropDownWidgetConstants.arrowPaddingTop,
      child: arrow,
    );
  }

  double get _getHeightList => min(widget.height * widget.data.length,
      widget.height * widget.countItemExpandList);

  Color get _getColorBackground =>
      _isShowList ? widget.backgroundListColor : widget.backgroundColor;
  BorderRadius get _boderRadius => const BorderRadius.all(
        Radius.circular(DropDownWidgetConstants.borderRadius),
      );

  Widget _buildList() {
    final RenderBox box = _globalKey.currentContext.findRenderObject();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _boderRadius,
        border: Border.all(
          color: widget.borderColor ?? Theme.of(context).accentColor,
          width: DropDownWidgetConstants.borderWidth,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_isShowList && widget.showLabelInList) _renderLabelDefaultItem(),
          Container(
            width: box.size.width,
            height: _getHeightList,
            child: Scrollbar(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: _buildListItems(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderLabelDefaultItem() {
    return GestureDetector(
      key: DropDownWidgetKeys.labelDefault,
      onTap: () {
        _hide();
        setState(() {
          _noneChoose = true;
        });
      },
      child: Container(
        alignment: Alignment.centerLeft,
        height: widget.height,
        padding: const EdgeInsets.only(
            left: DropDownWidgetConstants.arrowPaddingTop),
        child: Material(
          color: Colors.transparent,
          child: Text(
            widget.label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
