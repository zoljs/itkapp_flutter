import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/ui/absolutorium/viewmodels/subject_search_viewmodel.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:provider/provider.dart';

sealed class SubjectSearchResult {
  const SubjectSearchResult();
}

final class PickedSubject extends SubjectSearchResult {
  const PickedSubject(this.subject);

  final CurriculumSubject subject;
}

final class AddAsCustom extends SubjectSearchResult {
  const AddAsCustom(this.name);

  final String name;
}

class SubjectSearchScreen extends StatefulWidget {
  const SubjectSearchScreen(
      {super.key, this.selectedId, this.scrollController});

  final int? selectedId;
  final ScrollController? scrollController;

  @override
  State<SubjectSearchScreen> createState() => _SubjectSearchScreenState();
}

class _SubjectSearchScreenState extends State<SubjectSearchScreen> {
  final _controller = TextEditingController();
  late final SubjectSearchViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SubjectSearchViewModel(
        repository: context.read<AbsolutoriumRepository>());
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildResults(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final q = _viewModel.query;
    final hits = _viewModel.hits;
    final searching = _viewModel.search.running;

    if (_viewModel.queryTooShort) {
      return const StateMessage(
        icon: Icons.search_rounded,
        message:
            'Írj be legalább 2 karaktert (név vagy kód).\nElírva, ékezet nélkül vagy rövidítve is megtalálja.',
      );
    }
    if (searching && hits.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_viewModel.search.errorMessage case final message?) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        message: message,
        onRetry: () => _viewModel.search.execute(q),
      );
    }
    if (hits.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StateMessage(
              icon: Icons.search_off_rounded,
              message: 'Nincs találat a tantervedben erre: „$q”'),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.tonalIcon(
            onPressed: () =>
                Navigator.pop<SubjectSearchResult>(context, AddAsCustom(q)),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Felvétel saját tárgyként'),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: widget.scrollController,
      padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xxxl),
      itemCount: hits.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = hits[i];
        return InkWell(
          onTap: () =>
              Navigator.pop<SubjectSearchResult>(context, PickedSubject(s)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            style: TextStyle(
                                fontSize: 15, color: scheme.onSurface)),
                        Text(
                          [
                            s.code,
                            '${s.credits} kr',
                            if (s.requirementType != null) s.requirementType!
                          ].join(' · '),
                          style: TextStyle(
                              fontSize: 13, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (s.id == widget.selectedId)
                    Icon(Icons.check_rounded, color: scheme.primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_viewModel, _viewModel.search]),
      builder: (context, _) => Scaffold(
        backgroundColor: sheetBackgroundColor(context),
        appBar: buildBrandAppBar(context: context, title: 'Tárgy'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                AppSpacing.md,
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _viewModel.setQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Tárgy neve vagy kódja...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _viewModel.search.running &&
                          _viewModel.hits.isNotEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(child: _buildResults(context)),
          ],
        ),
      ),
    );
  }
}
