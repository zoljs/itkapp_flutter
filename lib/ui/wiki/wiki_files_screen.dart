import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_files_viewmodel.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class WikiFilesScreen extends StatelessWidget {
  const WikiFilesScreen({super.key, required this.viewModel});

  final WikiFilesViewModel viewModel;

  void _openItem(BuildContext context, WikiFile item) {
    if (item.isDir) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WikiFilesScreen(
            viewModel:
                WikiFilesViewModel.forDir(viewModel.childPath(item.name)),
          ),
        ),
      );
    } else {
      _openFile(context, item.name);
    }
  }

  Future<void> _openFile(BuildContext context, String name) async {
    final path = viewModel.childPath(name);
    final url =
        Uri.encodeFull('https://test.app.itk.ppke.hu/perpa4/files/$path');
    final uri = Uri.tryParse(url);

    final ok = uri != null &&
        uri.hasScheme &&
        await launchUrl(uri, mode: LaunchMode.inAppWebView);

    if (!ok && context.mounted) {
      context.showMessage('Nem sikerült megnyitni az oldalt.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = viewModel.title;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: buildBrandAppBar(title: title, context: context),
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.load]),
        builder: (context, _) {
          final loading = viewModel.load.running;
          final error = viewModel.load.errorMessage;
          final items = viewModel.items;

          if (loading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (error != null) {
            return StateMessage(
              icon: Icons.cloud_off_rounded,
              message: error,
              onRetry: viewModel.load.execute,
            );
          }

          if (items.isEmpty) {
            return const StateMessage(
              icon: Icons.folder_open_rounded,
              message: 'Ez a mappa üres.',
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 60,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final file = items[index];
              return SettingsTile(
                icon: file.isDir
                    ? Icons.folder_outlined
                    : Icons.insert_drive_file_outlined,
                title: file.name,
                trailing: Icon(file.isDir
                    ? Icons.chevron_right_rounded
                    : Icons.open_in_new_rounded),
                onTap: () => _openItem(context, file),
              );
            },
          );
        },
      ),
    );
  }
}
