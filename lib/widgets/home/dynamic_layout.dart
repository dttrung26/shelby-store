import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/packages.dart' show StoryWidget;
import '../../common/tools.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import '../blog/blog_grid.dart';
import 'banner/banner_animate_items.dart';
import 'banner/banner_group_items.dart';
import 'banner/banner_slider_items.dart';
import 'category/category_icon_items.dart';
import 'category/category_image_items.dart';
import 'header/header_search.dart';
import 'header/header_text.dart';
import 'horizontal/horizontal_list_items.dart';
import 'horizontal/instagram_items.dart';
import 'horizontal/simple_list.dart';
import 'horizontal/video/index.dart';
import 'logo.dart';
import 'product_list_layout.dart';

class DynamicLayout extends StatelessWidget {
  final config;
  final setting;

  DynamicLayout(this.config, this.setting);

  @override
  Widget build(BuildContext context) {
    switch (config['layout']) {
      case 'logo':
        return Logo(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'header_text':
        // if (kIsWeb) return Container();
        return HeaderText(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'header_search':
        if (kIsWeb) return Container();
        return HeaderSearch(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );
      case 'featuredVendors':
        return Services().widget.renderFeatureVendor(config);
      case 'category':
        return (config['type'] == 'image')
            ? CategoryImages(
                config: config,
                key: config['key'] != null ? Key(config['key']) : null,
              )
            : Consumer<CategoryModel>(builder: (context, model, child) {
                return CategoryIcons(
                  config: config,
                  categoryList: model.categoryList,
                  key: config['key'] != null ? Key(config['key']) : null,
                );
              });

      case 'bannerAnimated':
        if (kIsWeb) return Container();
        return BannerAnimated(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'bannerImage':
        if (config['isSlider'] == true) {
          return BannerSliderItems(
              config: config,
              key: config['key'] != null ? Key(config['key']) : null);
        }
        return BannerGroupItems(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'largeCardHorizontalListItems':
        return LargeCardHorizontalListItems(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'simpleVerticalListItems':
        return SimpleVerticalProductList(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'instagram':
        return InstagramItems(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'blog':
        return BlogGrid(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'video':
        return VideoLayout(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'story':
        return StoryWidget(
          config: config,
          onTapStoryText: (cfg) {
            Utils.onTapNavigateOptions(context: context, config: cfg);
          },
        );
      case 'fourColumn':
      case 'threeColumn':
      case 'twoColumn':
      case 'staggered':
      case 'recentView':
      case 'saleOff':
      case 'card':
      case 'listTile':
        return ProductListLayout(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      default:
        return const SizedBox();
    }
  }
}
