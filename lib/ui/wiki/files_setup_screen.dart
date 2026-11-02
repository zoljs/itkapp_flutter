import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/files_repository.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/wiki/viewmodels/files_setup_viewmodel.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

class FilesSetupScreen extends StatefulWidget {
  const FilesSetupScreen({super.key});

  @override
  State<FilesSetupScreen> createState() => _FilesSetupScreenState();
}

class _FilesSetupScreenState extends State<FilesSetupScreen> {
  late final FilesSetupViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FilesSetupViewModel(
      filesRepository: context.read<FilesRepository>(),
      authRepository: context.read<AuthRepository>(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    context.showMessage('Másolva.');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _viewModel.check,
      builder: (context, _) {
        final check = _viewModel.check;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: buildBrandAppBar(context: context, title: 'Fájlkezelő beállítása'),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg + MediaQuery.paddingOf(context).top + kToolbarHeight,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SettingsGroup(
                  header: '1. Belépés',
                  footer: 'Terminálban, az egyetemi jelszavaddal.',
                  children: [
                    _CommandTile(
                      command: _viewModel.sshCommand,
                      onCopy: () => unawaited(_copy(_viewModel.sshCommand)),
                    ),
                  ],
                ),
                SettingsGroup(
                  header: '2. Telepítés',
                  footer: 'Letölti a fájlkezelőt a public_html mappádba. Frissítéshez futtasd újra ugyanezt.',
                  children: [
                    _CommandTile(
                      command: FilesSetupViewModel.installCommand,
                      onCopy: () => unawaited(_copy(FilesSetupViewModel.installCommand)),
                    ),
                  ],
                ),
                SettingsGroup(
                  header: '3. Fájlok',
                  footer: 'Ide tedd a megosztani kívánt fájlokat. Az almappák is megjelennek.',
                  children: [
                    _CommandTile(
                      command: '~/public_html/files',
                      onCopy: () => unawaited(_copy('~/public_html/files')),
                    ),
                  ],
                ),
                BrandButton(
                  onTap: check.running ? null : () => unawaited(check.execute()),
                  height: 52,
                  backgroundColor: scheme.primaryContainer,
                  child: Center(
                    child: check.running
                        ? const CircularProgressIndicator.adaptive()
                        : Text(
                            'Ellenőrzés',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                  ),
                ),
                if (check.result case final result?) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _ResultBox(result: result),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A shell command in monospace with a copy button.
class _CommandTile extends StatelessWidget {
  const _CommandTile({required this.command, required this.onCopy});

  final String command;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              command,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: ['Menlo', 'Courier'],
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Másolás',
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}

/// Success or the error message of the last check.
class _ResultBox extends StatelessWidget {
  const _ResultBox({required this.result});

  final Result<List<WikiFile>> result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (icon, message, background, foreground) = switch (result) {
      Ok(:final value) => (
          Icons.check_circle_rounded,
          value.isEmpty ? 'Működik! A files mappa még üres.' : 'Működik! ${value.length} elem van a files mappában.',
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      Err(:final message) => (
          Icons.error_outline_rounded,
          message,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message, style: TextStyle(color: foreground))),
          ],
        ),
      ),
    );
  }
}
