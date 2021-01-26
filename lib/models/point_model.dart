import 'package:flutter/material.dart';

import '../services/index.dart';
import 'entities/point.dart';

class PointModel extends ChangeNotifier {
  final Services _service = Services();
  Point point;

  Future<void> getMyPoint(String token) async {
    try {
      point = await _service.api.getMyPoint(token);
      notifyListeners();
    } catch (err) {
      notifyListeners();
    }
  }
}
