import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class SaleDatePickers extends StatelessWidget {
  final Function onDateFromCallBack;
  final Function onDateToCallBack;
  final DateTime dateFrom;
  final DateTime dateTo;
  const SaleDatePickers(
      {Key key,
      this.onDateFromCallBack,
      this.onDateToCallBack,
      this.dateFrom,
      this.dateTo})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    void _setDateTo() async {
      final picked = await showDatePicker(
          context: context,
          initialDate: dateTo ?? DateTime.now(),
          firstDate: dateFrom ?? DateTime.now(),
          lastDate: DateTime(2101));
      if (picked != null && picked != dateTo) {}
    }

    void _setDateFrom() async {
      final picked = await showDatePicker(
          context: context,
          initialDate: dateFrom ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101));
      if (picked != null && picked != dateFrom) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Text(S.of(context).from),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: _setDateFrom,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 10),
                    const Text('30/07/1994'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Text(S.of(context).to),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: _setDateTo,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 10),
                    const Text('30/07/1994'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
