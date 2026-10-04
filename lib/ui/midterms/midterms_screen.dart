import 'package:flutter/material.dart';
import 'package:itk_app/data/services/midterms_service.dart';
import 'package:itk_app/domain/models/midterm_date.dart';
import 'package:itk_app/utils/result.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';

class MidtermsScreen extends StatefulWidget {
  const MidtermsScreen({super.key});

  @override
  State<MidtermsScreen> createState() => _MidtermsScreenState();
}

class _MidtermsScreenState extends State<MidtermsScreen> {
  List<MidtermDate> _midterms = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final result = await MidtermsService.instance.getMidterms();
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _midterms = value;
          _loading = false;
        });
      case Err(:final message):
        setState(() {
          _error = message;
          _loading = false;
        });
    }
  }

  String _formatDate(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}.${two(l.month)}.${two(l.day)}. ${two(l.hour)}:${two(l.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _error!,
        onRetry: _load,
      );
    } else if (_midterms.isEmpty) {
      body = const StateMessage(
        icon: Icons.event_available_rounded,
        message: 'Nincs közelgő ZH.',
      );
    } else {
      body = ListView.builder(
        itemCount: _midterms.length,
        itemBuilder: (context, index) {
          final m = _midterms[index];
          return ListTile(
            title: Text('${m.subject.code} – ${m.subject.name}'),
            subtitle: Text(
              [_formatDate(m.startsAt), if (m.location != null) m.location!]
                  .join(' · '),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ZH időpontok')),
      body: body,
    );
  }
}
