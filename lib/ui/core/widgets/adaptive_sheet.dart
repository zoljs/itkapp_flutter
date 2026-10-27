import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Color sheetBackgroundColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.bottomSheetTheme.modalBackgroundColor ?? theme.colorScheme.surfaceContainerLow;
}

void closeSheet(BuildContext context) {
  CupertinoSheetRoute.popSheet(context);
}

Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext, ScrollController?) builder,
}) {
  return showCupertinoSheet<T>(
    context: context,
    showDragHandle: true,
    useNestedNavigation: true,
    scrollableBuilder: (context, controller) => ColoredBox(
      color: sheetBackgroundColor(context),
      child: builder(context, controller),
    ),
  );
  // return showModalBottomSheet<T>(
  //   context: context,
  //   isScrollControlled: true,
  //   useSafeArea: true,
  //   showDragHandle: true,
  //   builder: (context) => builder(context, null),
  // );
}
