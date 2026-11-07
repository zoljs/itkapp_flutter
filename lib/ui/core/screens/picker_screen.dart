import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/screens/viewmodels/picker_viewmodel.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/picker_search_field.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PickerScreen<T> extends StatefulWidget {
  const PickerScreen({
    super.key,
    required this.viewModel,
    required this.title,
    required this.hintText,
    required this.skeletonItems,
    required this.tileBuilder,
    required this.closesSheet,
    this.actionIcon = Icons.check_rounded,
    this.onAction,
    this.scrollController,
  });

  final PickerViewModel<T> viewModel;
  final String title;
  // Search bar
  final String hintText;

  // Items
  final List<T> skeletonItems;
  final Widget Function(BuildContext context, T item) tileBuilder;

  // Leading and trailing
  final bool closesSheet;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final ScrollController? scrollController;

  @override
  State<PickerScreen<T>> createState() => _PickerScreenState();
}

class _PickerScreenState<T> extends State<PickerScreen<T>> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    // Widget does not create it, therefore must not dispose of it
    //widget.viewModel.dispose();
    super.dispose();
  }

  Widget _buildList(BuildContext context) {
    final loading = widget.viewModel.load.running;
    final items =
        loading ? widget.skeletonItems : widget.viewModel.filteredItems;

    if (widget.viewModel.load.errorMessage != null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        message: widget.viewModel.load.errorMessage!,
        onRetry: widget.viewModel.load.execute,
      );
    }

    return Skeletonizer(
      enabled: loading,
      child: ListView.separated(
        controller: widget.scrollController,
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 80,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            widget.tileBuilder(context, items[index]),
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sheetBackgroundColor(context),
      appBar: buildBrandAppBar(
        closesSheet: widget.closesSheet,
        actionIcon: widget.actionIcon,
        onAction: widget.onAction,
        context: context,
        title: widget.title,
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    return _buildList(context);
                  })),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PickerSearchField(
              searchController: _searchController,
              onChanged: widget.viewModel.setQuery,
              hintText: widget.hintText,
            ),
          ),
        ],
      ),
    );
  }
}
