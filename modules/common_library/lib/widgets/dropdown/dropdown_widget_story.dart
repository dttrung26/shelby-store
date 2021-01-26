import 'package:flutter/material.dart';

import 'dropdown_widget.dart';

class ExampleDropDownWidget extends StatefulWidget {
  @override
  _ExampleDropDownWidgetState createState() => _ExampleDropDownWidgetState();
}

class _ExampleDropDownWidgetState extends State<ExampleDropDownWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: DropDownWidget(
                          width: double.infinity,
                          label: 'Frequency',
                          data: [
                            DropDownWidgetItem(id: '1', value: 'Yearly'),
                            DropDownWidgetItem(id: '1', value: 'Monthly'),
                            DropDownWidgetItem(id: '1', value: 'Weekly'),
                            DropDownWidgetItem(id: '1', value: 'Daily'),
                          ],
                          dropDownExpandType: DropDownExpandType.down,
                          onChanged: (DropDownWidgetItem data, int index) {
                            // LOG.verbose(
                            //     '[DropDownWidget] data: ${data.toString()}');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropDownWidget(
                        width: 123,
                        data: [
                          DropDownWidgetItem(id: '1', value: 'Monday'),
                          DropDownWidgetItem(id: '1', value: 'Tuesday'),
                          DropDownWidgetItem(id: '1', value: 'Wednesday'),
                          DropDownWidgetItem(id: '1', value: 'Thursday'),
                          DropDownWidgetItem(id: '1', value: 'Friday'),
                        ],
                        dropDownExpandType: DropDownExpandType.down,
                        onChanged: (DropDownWidgetItem data, int index) {
                          // LOG.verbose(
                          //     '[DropDownWidget] data: ${data.toString()}');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
                DropDownWidget(
                  width: 88,
                  data: [
                    DropDownWidgetItem(id: '1', value: '1'),
                    DropDownWidgetItem(id: '1', value: '2'),
                    DropDownWidgetItem(id: '1', value: '3'),
                    DropDownWidgetItem(id: '1', value: '3'),
                    DropDownWidgetItem(id: '1', value: '3'),
                    DropDownWidgetItem(id: '1', value: '3'),
                    DropDownWidgetItem(id: '1', value: '3'),
                  ],
                  dropDownExpandType: DropDownExpandType.down,
                  label: 'No.',
                  countItemExpandList: 4,
                  onChanged: (DropDownWidgetItem data, int index) {},
                ),
                const SizedBox(height: 100),
                Container(
                  width: 400,
                  height: 400,
                  color: Theme.of(context).primaryColor,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: DropDownWidget(
                      width: 307,
                      data: [
                        DropDownWidgetItem(id: '1', value: 'Ask me 1'),
                        DropDownWidgetItem(id: '1', value: 'Ask me 1'),
                        DropDownWidgetItem(
                            id: '1',
                            value: 'Ask me if transaction is above my limit'),
                      ],
                      backgroundColor: Colors.white,
                      backgroundListColor: Colors.white,
                      borderColor: Colors.white,
                      dropDownExpandType: DropDownExpandType.down,
                      label: 'Goal for activation',
                      showLabelInList: true,
                      labelValueDefault: '- Choose Option -',
                      onChanged: (DropDownWidgetItem data, int index) {
                        // LOG.verbose('[DropDownWidget]: ${data.toString()}');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
