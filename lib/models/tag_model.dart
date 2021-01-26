import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../app.dart';
import '../common/constants.dart';
import '../services/index.dart';
import 'app_model.dart';
import 'entities/tag.dart';

class TagModel with ChangeNotifier {
  final Services _service = Services();
  Map<String, Tag> tags;
  List<Tag> tagList;

  bool isLoading = false;
  String message;

  StreamSubscription _subLanguageChange;

  TagModel() {
    _subLanguageChange = eventBus.on<EventChangeLanguage>().listen((event) {
      getTags();
    });
  }

  @override
  void dispose() {
    _subLanguageChange?.cancel();
    super.dispose();
  }

  String get langCode =>
      Provider.of<AppModel>(App.fluxStoreNavigatorKey.currentContext,
              listen: false)
          .langCode;

  Future<void> getTags() async {
    try {
      printLog('[Tag] getTags');
      isLoading = true;
      notifyListeners();
      tags = await _service.api.getTags(lang: langCode);
      if (tags == null) {
        tagList = [];
        isLoading = false;
        notifyListeners();
        return;
      }
      tagList = tags.values.toList();

      message = null;
      isLoading = false;
      notifyListeners();
    } catch (err, _) {
      tagList = [];
      isLoading = false;
      message = 'There is an issue with the app during request the data, '
              'please contact admin for fixing the issues ' +
          err.toString();
      notifyListeners();
    }
  }

  static Map<String, Tag> parseTagList(response) {
    /// API may return duplicate tags. Need to store in a map.
    var tags = <String, Tag>{};
    if (response is Map && isNotBlank(response['message'])) {
      throw Exception(response['message']);
    } else {
      for (var item in response) {
        final tag = Tag.fromJson(item);
        tags[tag.id.toString()] = tag;
      }
      return tags;
    }
  }
}
