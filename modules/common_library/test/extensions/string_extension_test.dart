import 'package:flutter_test/flutter_test.dart';
import 'package:inspireui/extensions/string_extension.dart';

void main() {
  test('string verify isEmptyOrNull', () {
    String s;
    expect(s.isEmptyOrNull, true);
    expect(''.isEmptyOrNull, true);
    expect('a'.isEmptyOrNull, false);
  });

  test('string verify toSpaceSeparated', () {
    const s = 'aaa s';
    expect(s.toSpaceSeparated != null, true);
  });

  test('string verify formatCopy', () {
    expect('{ "a": 1}'.formatCopy(), '{ "a": 1}');
  });

  test('isURLImage verify formatCopy', () {
    expect('https://abc.com/a.png'.isURLImage, true);
    expect('c.com/a.png'.isURLImage, false);
  });
}
