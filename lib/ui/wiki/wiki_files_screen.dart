import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_files_viewmodel.dart';
import 'package:itk_app/utils/open_link.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class WikiFilesScreen extends StatefulWidget {
  const WikiFilesScreen({super.key, required this.viewModel});

  final WikiFilesViewModel viewModel;

  @override
  State<WikiFilesScreen> createState() => _WikiFilesScreenState();
}

class _WikiFilesScreenState extends State<WikiFilesScreen> {
  static final _skeletonItems = List.generate(
    8,
    (i) => WikiFile(name: BoneMock.words(i.isEven ? 2 : 3), isDir: i < 2),
  );

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  void _openItem(BuildContext context, WikiFile item) {
    if (item.isDir) {
      final dir = widget.viewModel.childPath(item.name);
      final uri = Uri(
          path: Routes.filesFor(widget.viewModel.user),
          queryParameters: {'dir': dir}).toString();

      unawaited(context.push(uri));
    } else {
      unawaited(_openFile(context, item.name));
    }
  }

  Future<void> _openFile(BuildContext context, String name) async =>
      openLink(context, widget.viewModel.fileUrl(name),
          mode: LaunchMode.inAppWebView);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: buildBrandAppBar(title: widget.viewModel.title, context: context),
      body: ListenableBuilder(
        listenable: Listenable.merge([widget.viewModel, widget.viewModel.load]),
        builder: (context, _) {
          final load = widget.viewModel.load;
          final items = widget.viewModel.items;
          final showSkeleton = load.running && items.isEmpty;
          final error = load.errorMessage;

          if (!showSkeleton && error != null && items.isEmpty) {
            return StateMessage(
              icon: Icons.cloud_off_rounded,
              message: error,
              onRetry: () => unawaited(load.execute()),
            );
          }

          if (!showSkeleton && items.isEmpty) {
            return const StateMessage(
              icon: Icons.folder_open_rounded,
              message: 'Ez a mappa üres.',
            );
          }

          final shown = showSkeleton ? _skeletonItems : items;

          return RefreshIndicator.adaptive(
            onRefresh: load.execute,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxxl + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Skeletonizer(
                  enabled: showSkeleton,
                  child: SettingsGroup(
                    header: showSkeleton ? 'Betöltés...' : _summary(items),
                    children: [
                      for (final file in shown)
                        _FileTile(
                          file: file,
                          onTap: showSkeleton
                              ? null
                              : () => _openItem(context, file),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _summary(List<WikiFile> items) {
    final dirs = items.where((f) => f.isDir).length;
    final files = items.length - dirs;

    return [
      if (dirs > 0) '$dirs mappa',
      if (files > 0) '$files fájl',
    ].join(', ');
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.file, required this.onTap});

  final WikiFile file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style(file);

    return SettingsTile(
      icon: icon,
      iconColor: color,
      title: file.name,
      external: !file.isDir,
      onTap: onTap,
    );
  }

  static (IconData, Color) _style(WikiFile file) {
    if (file.isDir) return (Icons.folder_rounded, Colors.blue.shade600);

    final dot = file.name.lastIndexOf('.');
    final ext = dot > 0 ? file.name.substring(dot + 1).toLowerCase() : '';

    return switch (ext) {
      'pdf' => (Icons.picture_as_pdf_rounded, Colors.red.shade600),
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' || 'svg' => (
          Icons.image_rounded,
          Colors.purple.shade400
        ),
      'zip' || 'rar' || '7z' || 'tar' || 'gz' => (
          Icons.folder_zip_rounded,
          Colors.brown.shade400
        ),
      'doc' || 'docx' || 'odt' || 'txt' || 'md' => (
          Icons.description_rounded,
          Colors.indigo.shade400
        ),
      'ppt' || 'pptx' || 'odp' => (
          Icons.slideshow_rounded,
          Colors.orange.shade700
        ),
      'xls' || 'xlsx' || 'ods' || 'csv' => (
          Icons.table_chart_rounded,
          Colors.green.shade600
        ),
      'mp4' || 'mov' || 'mkv' || 'webm' => (
          Icons.movie_rounded,
          Colors.pink.shade400
        ),
      'c' ||
      'cpp' ||
      'h' ||
      'java' ||
      'py' ||
      'js' ||
      'ts' ||
      'dart' ||
      'html' ||
      'css' ||
      'php' =>
        (Icons.code_rounded, Colors.teal.shade600),
      _ => (Icons.insert_drive_file_rounded, Colors.blueGrey.shade400),
    };
  }
}
