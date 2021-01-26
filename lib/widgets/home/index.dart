import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/blog_model.dart';
import 'dynamic_layout.dart';
import 'logo.dart';
import 'preview/preview_overlay.dart';
import 'vertical.dart';

class HomeLayout extends StatefulWidget {
  final configs;
  final bool isPinAppBar;
  final bool isShowAppbar;

  HomeLayout({
    this.configs,
    this.isPinAppBar = false,
    this.isShowAppbar = true,
    Key key,
  }) : super(key: key);

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  List widgetData;

  bool isPreviewingAppBar = false;

  @override
  void initState() {
    /// init config data
    widgetData =
        List<Map<String, dynamic>>.from(widget.configs['HorizonLayout']) ?? [];
    if (widgetData.isNotEmpty && widget.isShowAppbar) {
      widgetData.removeAt(0);
    }

    /// init single vertical layout
    if (widget.configs['VerticalLayout'] != null) {
      Map verticalData =
          Map<String, dynamic>.from(widget.configs['VerticalLayout']);
      verticalData['type'] = 'vertical';
      widgetData.add(verticalData);
    }

    /// init multi vertical layout
    if (widget.configs['VerticalLayouts'] != null) {
      List verticalLayouts = widget.configs['VerticalLayouts'];
      for (var i = 0; i < verticalLayouts.length; i++) {
        Map verticalData = verticalLayouts[i];
        verticalData['type'] = 'vertical';
        widgetData.add(verticalData);
      }
    }

    eventBus.on<EventPreviewWidget>().listen((event) {
      if (event.previewIndex == 0) {
        setState(() {
          isPreviewingAppBar = event.isPreviewing;
        });
      }
    });

    super.initState();
  }

  @override
  void didUpdateWidget(HomeLayout oldWidget) {
    if (oldWidget.configs != widget.configs) {
      /// init config data
      List data =
          List<Map<String, dynamic>>.from(widget.configs['HorizonLayout']);
      if (data.isNotEmpty && widget.isShowAppbar) {
        data.removeAt(0);
      }

      /// init vertical layout
      if (widget.configs['VerticalLayout'] != null) {
        Map verticalData =
            Map<String, dynamic>.from(widget.configs['VerticalLayout']);
        verticalData['type'] = 'vertical';
        data.add(verticalData);
      }
      setState(() {
        widgetData = data;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.configs == null) return Container();

    ErrorWidget.builder = (error) {
      if (kReleaseMode) {
        return Container();
      }
      return Container(
        constraints: const BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
            color: Colors.lightBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5)),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

        /// Hide error, if you're developer, enable it to fix error it has
        child: Center(
          child: Text('Error in ${error.exceptionAsString()}'),
        ),
      );
    };

    List<dynamic> horizonLayout = widget.configs['HorizonLayout'] ?? [];

    Map config = horizonLayout.firstWhere(
        (element) => element['layout'] == 'logo',
        orElse: () => Map<String, dynamic>.from({}));

    return CustomScrollView(
      cacheExtent: 2000.0,
      slivers: [
        if (widget.isShowAppbar)
          SliverAppBar(
            brightness: Theme.of(context).brightness,
            pinned: widget.isPinAppBar,
            snap: true,
            floating: true,
            titleSpacing: 0,
            elevation: 0,
            forceElevated: true,
            backgroundColor: isPreviewingAppBar
                ? Colors.redAccent.withOpacity(0.1)
                : config['color'] != null
                    ? HexColor(config['color'])
                    : Theme.of(context).backgroundColor,
            title: Logo(
              config: config,
              key: config['key'] != null ? Key(config['key']) : null,
            ),
          ),
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await Provider.of<BlogModel>(context, listen: false).getBlogs();
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              var config = widgetData[index];

              /// if show app bar, the preview should plus +1
              var previewIndex = widget.isShowAppbar ? index + 1 : index;

              if (config['type'] != null && config['type'] == 'vertical') {
                return PreviewOverlay(
                  index: previewIndex,
                  child: VerticalLayout(
                    config: config,
                    key: config['key'] != null ? Key(config['key']) : null,
                  ),
                );
              }

              return PreviewOverlay(
                index: previewIndex,
                child: DynamicLayout(config, widget.configs['Setting']),
              );
            },
            childCount: widgetData.length,
          ),
        ),
      ],
    );
  }
}
