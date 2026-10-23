import 'package:flutter/material.dart';
import 'package:itk_app/data/services/wiki_files_service.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/result.dart';
import 'package:url_launcher/url_launcher.dart';

class WikiFilesScreen extends StatefulWidget {
  const WikiFilesScreen({super.key, this.dir = ''});

  final String dir;

  @override
  State<WikiFilesScreen> createState() => _WikiFilesScreenState();
}

class _WikiFilesScreenState extends State<WikiFilesScreen> {
  List<WikiFile> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await WikiFilesService.instance.listDir(widget.dir);
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _items = value;
          _loading = false;
        });
      case Err(:final message):
        setState(() {
          _error = message;
          _loading = false;
        });
    }
  }

  void _openItem(WikiFile item) {
    if (item.isDir) {
      final childDir =
          widget.dir.isEmpty ? item.name : '${widget.dir}/${item.name}';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WikiFilesScreen(dir: childDir)),
      );
    } else {
      _openFile(item.name);
    }
  }

  Future<void> _openFile(String name) async {
    final path = widget.dir.isEmpty ? name : '${widget.dir}/$name';
    final url =
        Uri.encodeFull('https://test.app.itk.ppke.hu/perpa4/files/$path');
    final uri = Uri.tryParse(url);

    final ok = uri != null &&
        uri.hasScheme &&
        await launchUrl(uri, mode: LaunchMode.inAppWebView);

    if (!ok && mounted) {
      context.showMessage('Nem sikerült megnyitni az oldalt.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.dir.isEmpty ? 'Fájlok' : widget.dir.split('/').last;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: buildBrandAppBar(title: title, context: context),
      body: Builder(
        builder: (context) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (_error != null) {
            return StateMessage(
              icon: Icons.cloud_off_rounded,
              message: _error!,
              onRetry: _load,
            );
          }

          if (_items.isEmpty) {
            return const StateMessage(
              icon: Icons.folder_open_rounded,
              message: 'Ez a mappa üres.',
            );
          }

          return ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 60,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final file = _items[index];
              return SettingsTile(
                icon: file.isDir
                    ? Icons.folder_outlined
                    : Icons.insert_drive_file_outlined,
                title: file.name,
                trailing: Icon(file.isDir
                    ? Icons.chevron_right_rounded
                    : Icons.open_in_new_rounded),
                onTap: () => _openItem(file),
              );
            },
          );
        },
      ),
    );
  }
}
