import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../models/blog_model.dart';
import '../../screens/base.dart';
import '../common/skeleton.dart';
import '../home/header/header_view.dart';
import '../layout/adaptive.dart';
import 'blog_grid_item.dart';

class BlogGrid extends StatefulWidget {
  final config;

  BlogGrid({
    Key key,
    this.config,
  }) : super(key: key);

  @override
  _BlogGridState createState() => _BlogGridState();
}

class _BlogGridState extends BaseScreen<BlogGrid> {
  PageController pageController;
  final viewportFraction = 0.9;

  @override
  void initState() {
    pageController = PageController(viewportFraction: viewportFraction);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget _buildHeader(context, blogs) {
    if (widget.config.containsKey('name')) {
      var showSeeAllLink = widget.config['layout'] != 'instagram';
      return HeaderView(
        headerText: widget.config['name'] ?? '',
        showSeeAll: showSeeAllLink,
        callback: () => Navigator.of(context).pushNamed(RouteList.blogs),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlogModel>(builder: (_, model, __) {
      final listBlog = model.blogs?.take(12);

      if (listBlog?.isEmpty ?? true) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenSize.height * 3 / 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: <Widget>[
                _buildHeader(context, null),
                const Expanded(child: _BlogViewSkeleton()),
                const Expanded(child: _BlogViewSkeleton()),
                const Expanded(child: _BlogViewSkeleton()),
              ],
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(context, listBlog),
          Container(
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 48),
              physics: isDisplayDesktop(context)
                  ? const BouncingScrollPhysics()
                  : const PageScrollPhysics(),
              controller: pageController,
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate((listBlog.length / 3).ceil(), (index) {
                  final items = listBlog.skip(index * 3).take(3);
                  return SizedBox(
                    width: screenSize.width * viewportFraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: items
                          .map((blog) => BlogGridItem(blog: blog))
                          .toList(),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _BlogViewSkeleton extends StatelessWidget {
  const _BlogViewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Flexible(
            flex: 4,
            child: Skeleton(),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(
                  width: 200,
                  height: 20,
                ),
                const SizedBox(height: 8),
                const Skeleton(
                  width: 100,
                  height: 16,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
