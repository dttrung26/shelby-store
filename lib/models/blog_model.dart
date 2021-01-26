import 'package:flutter/material.dart';

import '../services/index.dart';
import 'entities/blog.dart';

export 'entities/blog.dart';

class BlogModel with ChangeNotifier {
  List<Blog> _blogs;

  final _service = Services();

  List<Blog> get blogs => _blogs;

  dynamic _cursor;

  bool _isLoading = false;

  bool _hasNext = true;

  bool get isLoading => _isLoading;

  Future getBlogs() async {
    if (!_hasNext) return;
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    final blogData = await _service.api.getBlogs(
      cursor: _cursor,
      cursorCallback: (_) => _cursor = _,
    );

    if (blogData?.isEmpty ?? true) {
      _hasNext = false;
    }

    _blogs = [...blogs ?? [], ...blogData ?? []];
    await Future.delayed(const Duration(milliseconds: 300), () {
      _isLoading = false;
    });
    notifyListeners();
  }

  Future refresh() async {
    _cursor = null;
    _blogs = null;
    _hasNext = true;
    notifyListeners();
    return Future.delayed(const Duration(milliseconds: 300), getBlogs);
  }
}
