import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/screens/subject_multi_picker_screen.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_header.dart';
import 'package:itk_app/ui/wiki/viewmodels/my_site_viewmodel.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_color_picker.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_settings_group.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_tags_group.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class MySiteScreen extends StatefulWidget {
  const MySiteScreen({super.key});

  @override
  State<MySiteScreen> createState() => _MySiteScreenState();
}

class _MySiteScreenState extends State<MySiteScreen> {
  late final MySiteViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MySiteViewModel(
      wikiSitesRepository: context.read<WikiSitesRepository>(),
      authRepository: context.read<AuthRepository>(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await _viewModel.save.execute();
    if (!mounted) return;

    if (_viewModel.save.completed) {
      context.showMessage('Elmentve!');
    } else if (_viewModel.save.errorMessage case final message?) {
      context.showMessage(message);
    }
  }

  Future<void> _deleteSite() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Profil törlése',
      message: 'Biztosan törlöd a saját oldaladat? Ez nem vonható vissza.',
      confirmLabel: 'Törlés',
      isDestructive: true,
    );
    if (confirmed != true) return;

    await _viewModel.delete.execute();
    if (!mounted) return;

    if (_viewModel.delete.completed) {
      context.showMessage('Saját oldalad törölve lett.');
      Navigator.pop(context);
    } else if (_viewModel.delete.errorMessage case final message?) {
      context.showMessage(message);
    }
  }

  Future<void> _openTagPicker() async {
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => SubjectMultiPickerScreen(
        scrollController: controller,
        currentTags: _viewModel.tags,
        onSave: (result) => _viewModel.setTags(result),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final loading = _viewModel.load.running;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MySiteHeader(
            login: _viewModel.login,
            siteColor: _viewModel.color,
          ),
          MySiteColorPicker(
              selected: _viewModel.color, onSelected: _viewModel.setColor),
          MySiteSettingsGroup(
            loading: loading,
            isPublic: _viewModel.isPublic,
            onPublicChanged: (value) => _viewModel.setPublic(value),
            onOpenFileSetup: () => unawaited(context.push(Routes.wikiSetup)),
          ),
          MySiteTagsGroup(
            tags: _viewModel.tags,
            loading: loading,
            onAdd: _openTagPicker,
            onDelete: (tag) => _viewModel
                .setTags(_viewModel.tags.where((t) => t != tag).toList()),
          ),
          if (_viewModel.hasExistingSite) ...[
            BrandButton(
              onTap: _deleteSite,
              backgroundColor: scheme.errorContainer,
              foregroundColor: scheme.error,
              child: const Text(
                'Oldal törlése',
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final loading = _viewModel.load
              .running; // reminder for me, always calculate this inside the listenable

          return Scaffold(
            appBar: buildBrandAppBar(
              context: context,
              title: _viewModel.hasExistingSite
                  ? 'Saját oldalam'
                  : 'Oldal létrehozása',
              actionEnabled: !loading,
              onAction: loading
                  ? null
                  : () async {
                      await _submit();
                      if (!context.mounted) return;
                      if (_viewModel.save.completed) Navigator.pop(context);
                    },
            ),
            body: _buildForm(context),
          );
        });
  }
}
