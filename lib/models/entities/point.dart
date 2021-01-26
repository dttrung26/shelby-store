class Point {
  int points;
  double cartPriceRate;
  int cartPointsRate;

  Point.fromJson(Map<String, dynamic> parsedJson) {
    points = parsedJson['points'];
    cartPriceRate = parsedJson['cart_price_rate'];
    cartPointsRate = parsedJson['cart_points_rate'];
  }
}
