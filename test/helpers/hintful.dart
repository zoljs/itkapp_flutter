import 'package:flutter_test/flutter_test.dart';
import 'package:hintful/hintful.dart';

/// Marks every hint tour as already seen, so a screen that starts a tour in
/// its first frame does not put an overlay on top of the widgets under test.
void silenceHintTours() {
  Hintful.configure(
    store: CallbackHintStore(read: (_) => 'true', write: (_, __) {}),
  );
  addTearDown(Hintful.reset);
}
