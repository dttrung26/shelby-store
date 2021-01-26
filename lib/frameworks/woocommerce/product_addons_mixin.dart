import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart' show S;
import '../../models/index.dart'
    show AddonsOption, AppModel, Product, ProductAddons, UserModel;
import '../../services/index.dart';

mixin ProductAddonsMixin {
  bool get mediaTypeAllowed =>
      (kProductAddons['allowImageType'] ?? true) ||
      (kProductAddons['allowVideoType'] ?? true);

  bool isUploading = false;

  bool get customTypeAllowed => (kProductAddons['allowCustomType'] ?? false);

  FileType get allowedCustomFileType {
    final allowedTypes = kProductAddons['allowedCustomType'];
    if ((kProductAddons['allowCustomType'] ?? false) &&
        (allowedTypes is List && allowedTypes.isNotEmpty)) {
      return FileType.custom;
    }
    if ((kProductAddons['allowCustomType'] ?? false) &&
        (allowedTypes == null ||
            (allowedTypes is List && allowedTypes.isEmpty))) {
      return FileType.any;
    }
    throw Exception('No file type is supported!');
  }

  FileType get allowedMediaFileType {
    if ((kProductAddons['allowImageType'] ?? true) &&
        (kProductAddons['allowVideoType'] ?? true)) {
      return FileType.media;
    }
    if ((kProductAddons['allowImageType'] ?? true) &&
        !(kProductAddons['allowVideoType'] ?? true)) {
      return FileType.image;
    }
    if (!(kProductAddons['allowImageType'] ?? true) &&
        (kProductAddons['allowVideoType'] ?? true)) {
      return FileType.video;
    }
    throw Exception('No file type is supported!');
  }

  Future<void> getProductAddons({
    BuildContext context,
    Product product,
    Function(
            {Product productInfo,
            Map<String, Map<String, AddonsOption>> selectedOptions})
        onLoad,
    Map<String, Map<String, AddonsOption>> selectedOptions,
  }) async {
    final lang = Provider.of<AppModel>(context, listen: false).langCode;
    await Services()
        .api
        .getProduct(product.id, lang: lang)
        .then((onValue) async {
      if (onValue?.addOns?.isNotEmpty ?? false) {
        /// Select default options.
        selectedOptions.addAll(onValue.defaultAddonsOptions);

        onLoad(productInfo: onValue, selectedOptions: selectedOptions);
      }
    });
    return null;
  }

  List<Widget> getProductAddonsWidget({
    BuildContext context,
    String lang,
    Product product,
    Map<String, Map<String, AddonsOption>> selectedOptions,
    Function onSelectProductAddons,
  }) {
    final rates = Provider.of<AppModel>(context).currencyRate;
    final listWidget = <Widget>[];
    if (product.addOns?.isNotEmpty ?? false) {
      listWidget.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight.withOpacity(0.7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).options.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  S.of(context).total,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                Tools.getCurrencyFormatted(product.productOptionsPrice, rates),
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      );
      listWidget.add(ExpansionPanelList.radio(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        initialOpenPanelValue: 0,
        children: product.addOns.map<ExpansionPanelRadio>((ProductAddons item) {
          final selected = (selectedOptions[item.name] ?? {});
          return ExpansionPanelRadio(
            canTapOnHeader: true,
            value: item.name,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                visualDensity: VisualDensity.compact,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        item.name,
                      ),
                    ),
                    (item.isRadioButtonType && item.required)
                        ? Text(
                            S.of(context).mustSelectOneItem,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).accentColor,
                            ),
                          )
                        : const Text('')
                  ],
                ),
                subtitle: selected.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          item.isTextAreaType
                              ? (selected[item.name]?.label ?? '')
                              : selected.keys
                                  .toString()
                                  .replaceAll('(', '')
                                  .replaceAll(')', ''),
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      )
                    : Container(),
                contentPadding: EdgeInsets.zero,
              );
            },
            body: Wrap(
              children: List.generate(item.options.length, (index) {
                final option = item.options[index];
                final isSelected = selected[option.label] != null;
                final onTap = () {
                  if (item.isRadioButtonType) {
                    selected.clear();
                    selected[option.label] = option;
                    onSelectProductAddons(selectedOptions: selectedOptions);
                    return;
                  }
                  if (item.isCheckboxType) {
                    if (isSelected) {
                      selected.remove(option.label);
                    } else {
                      selected[option.label] = option;
                    }
                    onSelectProductAddons(selectedOptions: selectedOptions);
                    return;
                  }
                };
                return Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.45,
                  ),
                  child: item.isFileUploadType
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            bottom: 8.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: StatefulBuilder(
                                    builder: (context, StateSetter setState) {
                                  return TextButton.icon(
                                    onPressed: (isUploading ?? false)
                                        ? null
                                        : () => _showOption(context,
                                                onFileUploadStart: () {
                                              isUploading = true;
                                              setState(() {});
                                            }, onFileUploaded:
                                                    (List<String> fileUrls) {
                                              isUploading = false;
                                              setState(() {});
                                              for (var url in fileUrls) {
                                                /// Overwrite previous file if not multiple files not allowed.
                                                var key = (kProductDetail[
                                                            'allowMultiple'] ??
                                                        false)
                                                    ? url.split('/').last
                                                    : item.name;
                                                selected[key] = AddonsOption(
                                                  parent: item.name,
                                                  label: '$url',
                                                );
                                                onSelectProductAddons(
                                                    selectedOptions:
                                                        selectedOptions);
                                              }
                                            }),
                                    icon: (isUploading ?? false)
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Theme.of(context)
                                                          .primaryColor),
                                            ),
                                          )
                                        : const Icon(
                                            FontAwesomeIcons.fileUpload,
                                          ),
                                    label: Text(
                                      '${(isUploading ?? false) ? S.of(context).uploading : S.of(context).uploadFile}'
                                          .toUpperCase(),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: onTap,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.isRadioButtonType)
                                Radio(
                                  visualDensity: VisualDensity.compact,
                                  groupValue: selected.keys.isNotEmpty
                                      ? selected.keys.first
                                      : '',
                                  value: option.label,
                                  onChanged: (_) => onTap(),
                                  activeColor: Theme.of(context).primaryColor,
                                ),
                              if (item.isCheckboxType)
                                Checkbox(
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (_) => onTap(),
                                  activeColor: Theme.of(context).primaryColor,
                                  checkColor: Colors.white,
                                  value: isSelected,
                                ),
                              if (item.isTextAreaType)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: TextField(
                                      onChanged: (text) {
                                        if (text.isEmpty) {
                                          selected.remove(item.name);
                                          onSelectProductAddons(
                                              selectedOptions: selectedOptions);
                                          return;
                                        }

                                        if (selected[item.name] != null) {
                                          selected[item.name].label = text;
                                        } else {
                                          selected[item.name] = AddonsOption(
                                            parent: item.name,
                                            label: text,
                                          );
                                        }
                                        onSelectProductAddons(
                                            selectedOptions: selectedOptions);
                                      },
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(8),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        labelText: option.label,
                                      ),
                                      minLines: 1,
                                      maxLines: 4,
                                    ),
                                  ),
                                ),
                              if (!item.isTextAreaType)
                                Text(
                                  option.label,
                                  style: TextStyle(
                                    fontWeight:
                                        isSelected ? FontWeight.bold : null,
                                    fontSize: 14,
                                  ),
                                ),
                              if (!item.isTextAreaType)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(
                                    '(${Tools.getCurrencyFormatted(option.price, rates)})',
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected ? FontWeight.bold : null,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                );
              }),
            ),
          );
        }).toList(),
      ));
    }
    return listWidget;
  }

  void _showOption(BuildContext context,
      {VoidCallback onFileUploadStart,
      Function(List<String> fileUrl) onFileUploaded}) {
    showModalBottomSheet(
      context: context,
      builder: (_context) {
        return Container(
          padding:
              const EdgeInsets.only(bottom: 150, left: 20, right: 20, top: 20),
          child: Wrap(
            children: <Widget>[
              if (mediaTypeAllowed)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(_context);
                    selectFile(context, allowedMediaFileType,
                        onFileSelected: onFileUploaded,
                        onFileUploadStart: onFileUploadStart);
                  },
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        FontAwesomeIcons.image,
                        size: 60,
                      ),
                      Text(
                        S.of(context).gallery,
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 20),
              if (customTypeAllowed)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(_context);
                    selectFile(context, allowedCustomFileType,
                        onFileSelected: onFileUploaded,
                        onFileUploadStart: onFileUploadStart);
                  },
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        FontAwesomeIcons.file,
                        size: 60,
                      ),
                      Text(
                        S.of(context).files,
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> selectFile(BuildContext context, FileType fileType,
      {VoidCallback onFileUploadStart,
      Function(List<String> fileUrls) onFileSelected}) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: (kProductAddons['allowMultiple'] ?? false),
      type: fileType,
      allowedExtensions: fileType == FileType.custom
          ? kProductAddons['allowedCustomType']
          : null,
    );
    if (result?.files?.isEmpty ?? true) {
      /// Cancel select file.
      Tools.showSnackBar(
        Scaffold.of(context),
        S.of(context).selectFileCancelled,
      );
      return;
    }

    /// Check file size limit.
    final double fileSizeLimit = kProductAddons['fileUploadSizeLimit'] is double
        ? kProductAddons['fileUploadSizeLimit']
        : double.tryParse('${kProductAddons['fileUploadSizeLimit']}');
    if (fileSizeLimit != null && fileSizeLimit > 0.0) {
      for (var file in result.files) {
        if (file.size > (fileSizeLimit * 1000000)) {
          Tools.showSnackBar(
            Scaffold.of(context),
            S.of(context).fileIsTooBig,
          );
          return;
        }
      }
    }

    onFileUploadStart();

    try {
      final urls = <String>[];
      for (var file in result.files) {
        await Services().api.uploadImage({
          'title': {'rendered': path.basename(file.path)},
          'media_attachment': base64.encode(file.bytes)
        }, userModel.user != null ? userModel.user.cookie : null).then((photo) {
          urls.add(photo['guid']['rendered']);
        });
      }
      onFileSelected(urls);
    } catch (_) {
      try {
        Tools.showSnackBar(
          Scaffold.of(context),
          S.of(context).fileUploadFailed,
        );
      } catch (_) {}
    }
  }
}
