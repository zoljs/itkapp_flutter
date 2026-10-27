import 'package:flutter/material.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openLink(BuildContext context, String url, {LaunchMode mode = LaunchMode.externalApplication}) async {
  final uri = Uri.tryParse(url);
  final ok = uri != null && uri.hasScheme && await launchUrl(uri, mode: mode);
  if (!ok && context.mounted) {
    context.showMessage('Nem sikerült megnyitni a linket.');
  }
}
