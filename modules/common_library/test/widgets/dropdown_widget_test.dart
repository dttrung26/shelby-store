import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inspireui/test/material_test.dart';
import 'package:inspireui/widgets/dropdown/dropdown_widget.dart';

void main() {
  final data = [
    DropDownWidgetItem(key: const Key('1'), value: '1'),
    DropDownWidgetItem(key: const Key('1'), value: '2'),
    DropDownWidgetItem(key: const Key('1'), value: '3'),
    DropDownWidgetItem(key: const Key('1'), value: '3'),
    DropDownWidgetItem(key: const Key('1'), value: '3'),
    DropDownWidgetItem(key: const Key('1'), value: '3'),
    DropDownWidgetItem(key: const Key('1'), value: '3'),
  ];
  const key = ValueKey('DropDownWidget');
  testWidgets('should render dropdown down render susses',
      (WidgetTester tester) async {
    // Given
    final dropDownWidget = DropDownWidget(
      key: key,
      width: 307,
      data: data,
      dropDownExpandType: DropDownExpandType.down,
      onChanged: (DropDownWidgetItem data, int index) {},
    );
    final materialWidget = makeTestableWidget(child: dropDownWidget);
    final widget = materialWidget;

    //when
    await tester.pumpWidget(widget);

    //then
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
  });

  testWidgets('should render dropdown up with label render susses',
      (WidgetTester tester) async {
    // Given
    final dropDownWidget = DropDownWidget(
      key: key,
      width: 307,
      data: data,
      dropDownExpandType: DropDownExpandType.up,
      onChanged: (DropDownWidgetItem data, int index) {},
      label: 'label',
    );

    //when
    final materialWidget = makeTestableWidget(child: dropDownWidget);
    final widget = materialWidget;

    await tester.pumpWidget(widget);
    //then
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets(
      '''should user tap to dropdown button to show list view items to select item will hide list view''',
      (WidgetTester tester) async {
    // Given
    final dropDownWidget = DropDownWidget(
      key: key,
      width: 307,
      height: 50,
      data: data,
      dropDownExpandType: DropDownExpandType.center,
      onChanged: (DropDownWidgetItem data, int index) {},
      label: 'message',
      countItemExpandList: 3,
      showLabelInList: false,
    );

    //when
    final materialWidget = makeTestableWidget(child: dropDownWidget);
    final widget = materialWidget;
    await tester.pumpWidget(widget);

    //then
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
  });

  testWidgets(
      '''should user tap to dropdown button support label to show list view items to select item will hide list view''',
      (WidgetTester tester) async {
    // Given
    final dropDownWidget = DropDownWidget(
      key: key,
      width: 307,
      data: [
        DropDownWidgetItem(key: const Key('1'), value: '1'),
        DropDownWidgetItem(key: const Key('1'), value: '2'),
        DropDownWidgetItem(key: const Key('1'), value: '3'),
        DropDownWidgetItem(key: const Key('1'), value: '3'),
        DropDownWidgetItem(key: const Key('1'), value: '3'),
        DropDownWidgetItem(key: const Key('1'), value: '3'),
        DropDownWidgetItem(key: const Key('1'), value: '3'),
      ],
      backgroundColor: Colors.white,
      backgroundListColor: Colors.white,
      borderColor: Colors.white,
      dropDownExpandType: DropDownExpandType.down,
      label: 'Goal for activation',
      showLabelInList: true,
      labelValueDefault: '- Choose Option -',
    );
    //when
    final materialWidget = makeTestableWidget(child: dropDownWidget);
    final widget = materialWidget;

    await tester.pumpWidget(widget);

    // then
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
  });
}
