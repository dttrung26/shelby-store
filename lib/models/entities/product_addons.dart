class ProductAddons {
  String name;
  String description;
  String type;
  int position;
  List<AddonsOption> options;
  bool required;
  Map<String, AddonsOption> defaultOptions = {};

  ProductAddons({
    this.name,
    this.description,
    this.type,
    this.position,
    this.options,
    this.required = false,
  });

  bool get isRadioButtonType => type == 'multiple_choice';

  bool get isCheckboxType => type == 'checkbox';

  bool get isTextAreaType => type == 'custom_textarea';

  bool get isFileUploadType => type == 'file_upload';

  ProductAddons.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    type = json['type'];
    position = json['position'];
    required = json['required'] == 1;
    if (json['options'] != null) {
      final List<dynamic> values = json['options'] ?? [];
      options = List<AddonsOption>.generate(
        values.length,
        (index) {
          final option = AddonsOption.fromJson(values[index]);
          option.parent = name;
          if (option?.isDefault ?? false) {
            defaultOptions[option.label] = option;
          }
          return option;
        },
      );
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['description'] = description;
    data['type'] = type;
    data['position'] = position;
    data['required'] = (required ?? false) ? 1 : 0;
    if (options != null) {
      data['options'] = options.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddonsOption {
  String parent;
  String label;
  String price;
  bool isDefault;

  AddonsOption({this.parent, this.label, this.price, this.isDefault = false});

  AddonsOption.fromJson(Map<String, dynamic> json) {
    parent = json['parent'];
    label = json['label'];
    price = json['price'];
    isDefault = json['default'] == '1';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['parent'] = parent;
    data['label'] = label;
    data['price'] = price;
    data['default'] = (isDefault ?? false) ? '1' : '0';
    return data;
  }
}
