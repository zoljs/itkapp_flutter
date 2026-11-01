import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/events/viewmodels/add_event_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeEventRepository events;

  setUp(() => events = FakeEventRepository());

  AddEventViewModel create(Set<EventType> allowed) =>
      AddEventViewModel(repository: events, allowedTypes: allowed);

  test('az első engedélyezett típussal indul', () {
    final viewModel = create({EventType.midterm, EventType.retake});
    expect(viewModel.type, EventType.midterm);
    viewModel.dispose();

    final consultation = create({EventType.consultation});
    expect(consultation.type, EventType.consultation);
    consultation.dispose();
  });

  test('csak tárggyal, dátummal és időponttal menthető', () {
    final viewModel = create({EventType.midterm});
    expect(viewModel.canSave, isFalse);

    viewModel.setSubject(analysis);
    viewModel.setDate(DateTime(2026, 11, 3));
    expect(viewModel.canSave, isFalse);

    viewModel.setTime(const TimeOfDay(hour: 10, minute: 15));
    expect(viewModel.canSave, isTrue);
    viewModel.dispose();
  });

  test('a dátumot és az időpontot összerakja', () {
    final viewModel = create({EventType.midterm})
      ..setDate(DateTime(2026, 11, 3))
      ..setTime(const TimeOfDay(hour: 10, minute: 15));

    expect(viewModel.startsAt, DateTime(2026, 11, 3, 10, 15));
    viewModel.dispose();
  });

  test('mentéskor a kiválasztott típust és a tárgyat küldi', () async {
    final viewModel = create({EventType.midterm, EventType.retake})
      ..setSubject(analysis)
      ..setDate(DateTime(2026, 11, 3))
      ..setTime(const TimeOfDay(hour: 10, minute: 15))
      ..setType(EventType.retake)
      ..setLocation('  318  ');

    await viewModel.save.execute();

    expect(viewModel.save.completed, isTrue);
    expect(events.lastAdd?.subjectId, analysis.id);
    expect(events.lastAdd?.type, EventType.retake);
    expect(events.lastAdd?.location, '318');
    expect(events.lastAdd?.startsAt, DateTime(2026, 11, 3, 10, 15));
    viewModel.dispose();
  });

  test('üres helyszín null-ként megy', () async {
    final viewModel = create({EventType.consultation})
      ..setSubject(analysis)
      ..setDate(DateTime(2026, 11, 3))
      ..setTime(const TimeOfDay(hour: 10, minute: 0))
      ..setLocation('   ');

    await viewModel.save.execute();

    expect(events.lastAdd?.location, isNull);
    viewModel.dispose();
  });

  test('hiányzó adatokkal nem hív a szerverre', () async {
    final viewModel = create({EventType.midterm});

    await viewModel.save.execute();

    expect(viewModel.save.errorMessage, isNotNull);
    expect(events.lastAdd, isNull);
    viewModel.dispose();
  });

  test('a szerver hibája átjön', () async {
    events.addResult = const Err('Nincs jogosultság.');
    final viewModel = create({EventType.midterm})
      ..setSubject(analysis)
      ..setDate(DateTime(2026, 11, 3))
      ..setTime(const TimeOfDay(hour: 10, minute: 0));

    await viewModel.save.execute();

    expect(viewModel.save.errorMessage, 'Nincs jogosultság.');
    viewModel.dispose();
  });
}
