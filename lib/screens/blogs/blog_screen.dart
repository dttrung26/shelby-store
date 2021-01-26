import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/blog_model.dart';
import '../../widgets/blog/blog_list_item.dart';
import '../../widgets/common/skeleton.dart';
import '../base.dart';

class BlogScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BlogScreenState();
}

class _BlogScreenState extends BaseScreen<BlogScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !kIsWeb
          ? AppBar(
              elevation: 0.1,
              title: Text(
                S.of(context).blog,
                style: const TextStyle(color: Colors.white),
              ),
              leading: Center(
                child: GestureDetector(
                  onTap: () => {Navigator.pop(context)},
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : null,
      body: Consumer<BlogModel>(
        builder: (_, model, __) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.extentAfter < 500 &&
                  scrollInfo.metrics.extentBefore > 200) {
                model.getBlogs();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: model.refresh,
                ),
                model.blogs?.isEmpty ?? true
                    ? SliverList(
                        delegate: SliverChildListDelegate([
                          _buildSkeleton(),
                          _buildSkeleton(),
                          _buildSkeleton(),
                        ]),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => index == model.blogs.length
                              ? AnimatedSwitcher(
                                  child: model.isLoading
                                      ? _buildSkeleton()
                                      : const SizedBox(),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    final offsetAnimation = Tween<Offset>(
                                      begin: const Offset(0.0, 0.5),
                                      end: const Offset(0.0, 0.0),
                                    ).animate(animation);
                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                  duration: const Duration(milliseconds: 300),
                                )
                              : BlogListItem(blog: model.blogs[index]),
                          childCount: model.blogs.length + 1,
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 24.0,
        top: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Skeleton(height: 200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Skeleton(width: 120),
              const Skeleton(width: 80),
            ],
          ),
          const SizedBox(height: 16),
          const Skeleton(),
        ],
      ),
    );
  }
}
