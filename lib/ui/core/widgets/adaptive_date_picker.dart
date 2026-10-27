import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final today = DateUtils.dateOnly(DateTime.now());
  final first = firstDate ?? today;
  final initial = initialDate ?? first;
  final last = lastDate ?? DateTime(first.year + 1, first.month, first.day);

  if (!isIOS) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
  }

  var selected = initial;
  return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => CupertinoActionSheet(
            message: SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                minimumDate: first,
                maximumDate: last,
                onDateTimeChanged: (d) => selected = d,
              ),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Kész'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mégse'),
            ),
          ));
}

Future<TimeOfDay?> showAdaptiveTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

  if (!isIOS) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  var selected = initialTime;
  return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) => CupertinoActionSheet(
            message: SizedBox(
              height: 216,
              child: CupertinoDatePicker(
                use24hFormat: true,
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2000, 1, 1, initialTime.hour, initialTime.minute),
                onDateTimeChanged: (d) => selected = TimeOfDay.fromDateTime(d),
              ),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Kész'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mégse'),
            ),
          ));
}
