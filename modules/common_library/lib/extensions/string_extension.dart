extension StringExtensions on String {
  bool get hasOnlyWhitespaces => trim().isEmpty && isNotEmpty;

  bool get isEmptyOrNull {
    if (this == null) {
      return true;
    }
    return isEmpty;
  }

  String toSpaceSeparated() {
    final value =
        replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ');
    return value;
  }

  String formatCopy() {
    return replaceAll('},', '\n},\n')
        .replaceAll('[{', '[\n{\n')
        .replaceAll(',\"', ',\n\"')
        .replaceAll('{\"', '{\n\"')
        .replaceAll('}]', '\n}\n]');
  }

  bool get isNoInternetError => contains('SocketException: Failed host lookup');

  bool get isURLImage =>
      (isNotEmpty ?? false) && (contains('http') || contains('https'));
}
