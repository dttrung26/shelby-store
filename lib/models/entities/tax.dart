class Tax {
  String id;
  String title;
  double amount;

  Tax.fromJson(Map<String, dynamic> parsedJson) {
    title = parsedJson['label'];
    amount = double.parse('${(parsedJson['value'] ?? 0.0)}');
  }
}
