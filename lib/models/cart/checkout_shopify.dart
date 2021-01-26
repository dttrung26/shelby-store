class CheckoutCart {
  dynamic id;
  String webUrl;
  double subtotalPrice;
  double totalTax;
  double totalPrice;
  double paymentDue;

  CheckoutCart.fromJsonShopify(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    webUrl = parsedJson['webUrl'];
    subtotalPrice = double.parse(parsedJson['subtotalPrice'] ?? '0');
    totalTax = double.parse(parsedJson['totalTax'] ?? '0');
    totalPrice = double.parse(parsedJson['totalPrice'] ?? '0');
    paymentDue = double.parse(parsedJson['paymentDue'] ?? '0');
  }

  @override
  String toString() => 'Checkout { id: $id }';
}
