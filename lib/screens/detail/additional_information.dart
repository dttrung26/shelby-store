import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/index.dart' show ProductAttribute;
import '../../widgets/common/tooltip.dart' as tool_tip;

class AdditionalInformation extends StatelessWidget {
  final List<ProductAttribute> listInfo;

  AdditionalInformation({@required this.listInfo});

  @override
  Widget build(BuildContext context) {
    final lengthInfo = listInfo.length;
    return Column(
      children: [
        ...List.generate(
          listInfo.length,
          (index) {
            Color color;
            if (index.isEven && lengthInfo > 2) {
              color = Theme.of(context).primaryColorLight;
            }
            return renderItem(
              context: context,
              attribute: listInfo[index],
              color: color,
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget renderItem({
    context,
    ProductAttribute attribute,
    Color color,
  }) {
    if (attribute == null) return const SizedBox();

    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    Utils.capitalize(attribute.name),
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).accentColor,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 6,
              child: attribute.name != 'color'
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(attribute.options.join(', '),
                          style: const TextStyle(
                            color: kGrey600,
                            fontSize: 14,
                          )),
                    )
                  : Wrap(
                      runSpacing: 8.0,
                      spacing: 8.0,
                      children: <Widget>[
                        for (var i = 0; i < attribute.options.length; i++)
                          tool_tip.Tooltip(
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: HexColor(
                                  kNameToHex[attribute.options[i]
                                      .toString()
                                      .replaceAll(' ', '_')
                                      .toLowerCase()],
                                ),
                              ),
                            ),
                            message: attribute.options[i] ?? '',
                          )
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
