import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';

import '../../extensions/string_extension.dart';
import './widgets/story_text.dart';
import 'models/story.dart';
import 'story_constants.dart';

class StoryCard extends StatefulWidget {
  final double width;
  final Story story;
  final Function(Map) onTap;

  StoryCard({
    Key key,
    this.story,
    this.width,
    this.onTap,
  }) : super(key: key);

  @override
  _StoryCardState createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  double _width;
  double _opacity = 1;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _opacity = 1;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          _width = widget.width ?? constraint.maxWidth;
          final story = widget.story;
          return SizedBox(
            width: constraint.maxWidth,
            height: constraint.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                story?.urlImage?.isURLImage ?? false
                    ? ExtendedImage.network(
                        story.urlImage,
                        cache: true,
                        key: const ValueKey(StoryConstants.backgroundKey),
                        fit: BoxFit.cover,
                      )
                    : const Placeholder(),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        story?.contents?.length ?? 0,
                        (int index) => Padding(
                          padding: story.contents[index]?.getPadding(_width) ??
                              const EdgeInsets.only(),
                          child: Container(
                            key: ValueKey(
                                '${StoryConstants.storyItemKey}$index'),
                            padding: story.contents[index].spacing.padding,
                            margin: story.contents[index].spacing.margin,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 800),
                              opacity: _opacity,
                              child: GestureDetector(
                                key: ValueKey(
                                  '${StoryConstants.keyTextOfCardStory}$index',
                                ),
                                onTap: () {
                                  // ignore: omit_local_variable_types
                                  final Map config = {};
                                  if (story.contents[index].link?.isNotEmpty ??
                                      false) {
                                    if (story.contents[index].link.type ==
                                        'category') {
                                      config['category'] =
                                          story.contents[index].link.value;
                                      if (story.contents[index].link.tag
                                              ?.isNotEmpty ??
                                          false) {
                                        config['tag'] = int.parse(
                                            story.contents[index].link.tag);
                                      }
                                    } else {
                                      config[story.contents[index].link.type] =
                                          story.contents[index].link.value;
                                    }
                                  }
                                  widget?.onTap?.call(config);
                                  if (config['tab'] != null &&
                                      Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: StoryText(
                                  widget.story.contents[index],
                                  key: ValueKey(
                                      '${StoryConstants.textKey}$index'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
