import 'package:flutter_test/flutter_test.dart';
import 'package:fstore/common/config.dart';
import 'package:fstore/frameworks/woocommerce/services/woo_commerce.dart';

void main() {
  test('Wo service test', () async {
    // Give
    final serviceApi = WooCommerce()..appConfig(serverConfig);

    // When
    final list = await serviceApi.getCategories(lang: 'en');

    // Then
    expect(list != null, true);
  });
}
