import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/hungarian_phonology.dart';
import 'package:itk_app/domain/models/phoneme.dart';

void main() {
  group('készlet', () {
    test('14 magánhangzó és 25 mássalhangzó van', () {
      expect(HungarianPhonology.vowels, hasLength(14));
      expect(HungarianPhonology.consonants, hasLength(25));
    });

    test('minden IPA jel egyedi', () {
      final symbols = [
        for (final vowel in HungarianPhonology.vowels) vowel.ipa,
        for (final consonant in HungarianPhonology.consonants) consonant.ipa,
      ];
      expect(symbols.toSet(), hasLength(symbols.length));
    });

    test('a hosszú magánhangzók jele hosszúságjelre végződik', () {
      for (final vowel in HungarianPhonology.vowels) {
        expect(vowel.ipa.endsWith('ː'), vowel.long, reason: vowel.ipa);
      }
    });

    test('a példa átírása tartalmazza a hang jelét', () {
      final all = <Phoneme>[
        ...HungarianPhonology.vowels,
        ...HungarianPhonology.consonants,
      ];
      for (final phoneme in all) {
        expect(phoneme.exampleIpa, contains(phoneme.ipa), reason: phoneme.ipa);
      }
    });
  });

  group('vowelsAt', () {
    test('minden magánhangzó pontosan egy cellában van', () {
      final placed = <Vowel>[
        for (final height in VowelHeight.values)
          for (final backness in VowelBackness.values)
            for (final rounded in [false, true])
              ...HungarianPhonology.vowelsAt(
                height,
                backness,
                rounded: rounded,
              ),
      ];
      expect(placed, unorderedEquals(HungarianPhonology.vowels));
    });

    test('a rövid és hosszú pár egy cellába kerül, elöl a rövid', () {
      final cell = HungarianPhonology.vowelsAt(
        VowelHeight.close,
        VowelBackness.front,
        rounded: true,
      );
      expect([for (final vowel in cell) vowel.ipa], ['y', 'yː']);
    });

    test('egy cellában legfeljebb egy rövid és egy hosszú hang van', () {
      for (final height in VowelHeight.values) {
        for (final backness in VowelBackness.values) {
          for (final rounded in [false, true]) {
            final cell = HungarianPhonology.vowelsAt(
              height,
              backness,
              rounded: rounded,
            );
            expect(cell.where((vowel) => vowel.long).length, lessThan(2));
            expect(cell.where((vowel) => !vowel.long).length, lessThan(2));
          }
        }
      }
    });

    test('üres pozícióra üres listát ad', () {
      expect(
        HungarianPhonology.vowelsAt(
          VowelHeight.openMid,
          VowelBackness.back,
          rounded: false,
        ),
        isEmpty,
      );
    });
  });

  group('consonantsAt', () {
    test('minden mássalhangzó pontosan egy cellában van', () {
      final placed = <Consonant>[
        for (final manner in ConsonantManner.values)
          for (final column in ConsonantColumn.values)
            ...HungarianPhonology.consonantsAt(column, manner),
      ];
      expect(placed, unorderedEquals(HungarianPhonology.consonants));
    });

    test('egy cellában legfeljebb egy zöngétlen és egy zöngés hang van', () {
      for (final manner in ConsonantManner.values) {
        for (final column in ConsonantColumn.values) {
          final cell = HungarianPhonology.consonantsAt(column, manner);
          expect(cell.where((c) => c.voiced).length, lessThan(2),
              reason: '$column $manner');
          expect(cell.where((c) => !c.voiced).length, lessThan(2),
              reason: '$column $manner');
        }
      }
    });

    test('a labiális zárhangok cellája: p, b', () {
      final cell = HungarianPhonology.consonantsAt(
        ConsonantColumn.labial,
        ConsonantManner.plosive,
      );
      expect([for (final consonant in cell) consonant.ipa], ['p', 'b']);
    });
  });

  group('description', () {
    test('magánhangzó', () {
      final vowel =
          HungarianPhonology.vowels.firstWhere((v) => v.spelling == 'ő');
      expect(
        vowel.description,
        'hosszú, félig zárt, elöl képzett, ajakkerekítéses magánhangzó',
      );
    });

    test('mássalhangzó', () {
      final consonant =
          HungarianPhonology.consonants.firstWhere((c) => c.spelling == 'sz');
      expect(consonant.description, 'zöngétlen alveoláris réshang');
    });
  });

  group('isSameCell', () {
    test('azonos első hang esetén igaz, üres cellára hamis', () {
      final cell = HungarianPhonology.consonantsAt(
        ConsonantColumn.labial,
        ConsonantManner.plosive,
      );
      final again = HungarianPhonology.consonantsAt(
        ConsonantColumn.labial,
        ConsonantManner.plosive,
      );
      final other = HungarianPhonology.consonantsAt(
        ConsonantColumn.velar,
        ConsonantManner.plosive,
      );
      expect(isSameCell(cell, again), isTrue);
      expect(isSameCell(cell, other), isFalse);
      expect(isSameCell(cell, const []), isFalse);
      expect(isSameCell(const [], const []), isFalse);
    });
  });
}
