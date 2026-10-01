import 'package:flutter/material.dart';

class ComposeAppBarLarge extends StatefulWidget {
  final double collapseRange;
  final Color expandedColor;
  final Color collapsedColor;
  final Widget title;
  final Widget body;

  const ComposeAppBarLarge({
    super.key,
    required this.collapseRange,
    required this.expandedColor,
    required this.collapsedColor,
    required this.title,
    required this.body,
  });

  @override
  State<ComposeAppBarLarge> createState() => _ComposeAppBarLargeState();
}

class _ComposeAppBarLargeState extends State<ComposeAppBarLarge> {
  double _headerProgress = 0.0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double progress = _scrollController.offset / widget.collapseRange;
    double normalizedProgress = progress.clamp(0.0, 1.0);
    //print('offset=${_scrollController.offset} progress=$normalizedProgress');

    if (_headerProgress != normalizedProgress) {
      setState(() {
        _headerProgress = normalizedProgress;
      });
    }
  }

  void _snapHeader() {
    if (_scrollController.offset <= 0 ||
        _scrollController.offset >= widget.collapseRange) {
      return;
    }

    if (_scrollController.offset < widget.collapseRange / 3) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 200),
          curve: Easing.emphasizedDecelerate);
    } else {
      _scrollController.animateTo(widget.collapseRange,
          duration: const Duration(milliseconds: 200),
          curve: Easing.emphasizedDecelerate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color appBarColor = Color.lerp(
          widget.expandedColor,
          widget.collapsedColor,
          _headerProgress,
        ) ??
        widget.expandedColor;

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        _snapHeader();
        return false;
      },
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            backgroundColor: appBarColor,
            scrolledUnderElevation: 0,
            snap: false,
            floating: false,
            pinned: true,
            title: widget.title,
          ),
        ],
        body: widget.body,
      ),
    );
  }
}
