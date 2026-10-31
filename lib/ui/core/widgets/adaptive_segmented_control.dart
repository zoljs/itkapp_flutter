import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveSegmentedControl<T extends Object> extends StatelessWidget {
  const AdaptiveSegmentedControl({super.key, required this.values, required this.selected, required this.onChanged, required this.labelOf});

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS
        ? CupertinoSlidingSegmentedControl(
            groupValue: selected,
            children: {
              for (final item in values)
                item: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(labelOf(item)),
                ),
            },
            onValueChanged: (value) {
              if (value != null) onChanged(value);
            })
        : SegmentedButton<T>(
            showSelectedIcon: false,
            segments: [
              for (final item in values) ButtonSegment(value: item, label: Text(labelOf(item))),
            ],
            selected: {selected},
            onSelectionChanged: (selection) => onChanged(selection.first),
          );
  }
}
