import 'package:flutter/material.dart';

import '../card_zoom/card_zoom.dart';
import '../header_view/header_view.dart';
import './story_card.dart';
import './story_collection.dart';
import 'models/story_config.dart';
import 'story_constants.dart';

class StoryWidget extends StatefulWidget {
  final bool isFullScreen;
  final Map<String, dynamic> config;
  final bool showChat;
  final Function(Map) onTapStoryText;

  StoryWidget({
    Key key,
    @required this.config,
    this.onTapStoryText,
    this.isFullScreen = false,
    this.showChat = false,
  }) : super(key: key);

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  final List<StoryCard> _listStoryCard = [];
  StoryConfig _storyConfig;

  void _loadStory(Map config) {
    if (config != null) {
      _storyConfig = StoryConfig.fromJson(config);
      _listStoryCard.clear();
      if (_storyConfig?.data?.isNotEmpty ?? false) {
        List.generate(
          _storyConfig?.data?.length ?? 0,
          (index) {
            _listStoryCard.add(
              StoryCard(
                story: _storyConfig.data[index],
                key: ValueKey('story_$index'),
                onTap: widget.onTapStoryText,
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadStory(widget.config);

    if (_storyConfig?.active == false ?? false) {
      return const SizedBox();
    }

    if (widget.isFullScreen) {
      return StoryCollection(
        listStory: _listStoryCard,
        pageCurrent: 0,
        isHorizontal: _storyConfig.isHorizontal,
        showChat: widget.showChat,
        isTab: true,
      );
    } else {
      return _renderListCartStory();
    }
  }

  Widget _renderListCartStory() {
    const _space = SizedBox(width: 12.0);
    return Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          final _widthItem = (constraint.maxWidth -
                  (StoryConstants.spaceBetweenStory *
                      _storyConfig.countColumn)) /
              _storyConfig.countColumn;
          return Column(
            children: [
              HeaderView(
                headerText: _storyConfig.name ?? ' ',
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _space,
                    ...List.generate(
                      _listStoryCard?.length ?? 0,
                      (index) {
                        return Container(
                          width: _widthItem,
                          height: StoryConstants.aspectRatio * _widthItem - 10,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    left: StoryConstants.spaceBetweenStory),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      _storyConfig.radius),
                                  child: CardZoom.story(
                                    context: context,
                                    maxWidth: constraint.maxWidth,
                                    maxHeight: constraint.maxWidth *
                                        StoryConstants.aspectRatio,
                                    child: _listStoryCard[index],
                                  ),
                                ),
                              ),
                              _openFullScreenStory(context, index),
                            ],
                          ),
                        );
                      },
                    ),
                    _space,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _openFullScreenStory(BuildContext context, int index) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        key: ValueKey('${StoryConstants.storyTapKey}$index'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoryCollection(
                listStory: _listStoryCard,
                pageCurrent: index,
                isHorizontal: _storyConfig.isHorizontal,
              ),
            ),
          );
        },
      ),
    );
  }
}
