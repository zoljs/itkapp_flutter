import 'package:itk_app/domain/models/phoneme.dart';

/// The phoneme inventory of standard Hungarian: 14 vowels, 25 consonants.
///
/// Phonemic transcription with the usual IPA symbols (Szende 1994, Journal of
/// the IPA 24(2); Siptár and Törkenczy 2000). `ty` and `gy` are listed as
/// palatal plosives; some descriptions treat them as affricates.
///
/// `͡` is the combining tie bar of affricates, `ɡ` is the IPA
/// letter for the voiced velar plosive (not the ASCII `g`).
abstract final class HungarianPhonology {
  static const vowels = <Vowel>[
    Vowel(
      ipa: 'i',
      spelling: 'i',
      example: 'kis',
      exampleIpa: 'kiʃ',
      height: VowelHeight.close,
      backness: VowelBackness.front,
      rounded: false,
      long: false,
    ),
    Vowel(
      ipa: 'iː',
      spelling: 'í',
      example: 'víz',
      exampleIpa: 'viːz',
      height: VowelHeight.close,
      backness: VowelBackness.front,
      rounded: false,
      long: true,
    ),
    Vowel(
      ipa: 'y',
      spelling: 'ü',
      example: 'ül',
      exampleIpa: 'yl',
      height: VowelHeight.close,
      backness: VowelBackness.front,
      rounded: true,
      long: false,
    ),
    Vowel(
      ipa: 'yː',
      spelling: 'ű',
      example: 'tűz',
      exampleIpa: 'tyːz',
      height: VowelHeight.close,
      backness: VowelBackness.front,
      rounded: true,
      long: true,
    ),
    Vowel(
      ipa: 'u',
      spelling: 'u',
      example: 'tud',
      exampleIpa: 'tud',
      height: VowelHeight.close,
      backness: VowelBackness.back,
      rounded: true,
      long: false,
    ),
    Vowel(
      ipa: 'uː',
      spelling: 'ú',
      example: 'út',
      exampleIpa: 'uːt',
      height: VowelHeight.close,
      backness: VowelBackness.back,
      rounded: true,
      long: true,
    ),
    Vowel(
      ipa: 'eː',
      spelling: 'é',
      example: 'év',
      exampleIpa: 'eːv',
      height: VowelHeight.closeMid,
      backness: VowelBackness.front,
      rounded: false,
      long: true,
    ),
    Vowel(
      ipa: 'ø',
      spelling: 'ö',
      example: 'öt',
      exampleIpa: 'øt',
      height: VowelHeight.closeMid,
      backness: VowelBackness.front,
      rounded: true,
      long: false,
    ),
    Vowel(
      ipa: 'øː',
      spelling: 'ő',
      example: 'nő',
      exampleIpa: 'nøː',
      height: VowelHeight.closeMid,
      backness: VowelBackness.front,
      rounded: true,
      long: true,
    ),
    Vowel(
      ipa: 'o',
      spelling: 'o',
      example: 'ok',
      exampleIpa: 'ok',
      height: VowelHeight.closeMid,
      backness: VowelBackness.back,
      rounded: true,
      long: false,
    ),
    Vowel(
      ipa: 'oː',
      spelling: 'ó',
      example: 'tó',
      exampleIpa: 'toː',
      height: VowelHeight.closeMid,
      backness: VowelBackness.back,
      rounded: true,
      long: true,
    ),
    Vowel(
      ipa: 'ɛ',
      spelling: 'e',
      example: 'ez',
      exampleIpa: 'ɛz',
      height: VowelHeight.openMid,
      backness: VowelBackness.front,
      rounded: false,
      long: false,
    ),
    Vowel(
      ipa: 'aː',
      spelling: 'á',
      example: 'ház',
      exampleIpa: 'haːz',
      height: VowelHeight.open,
      backness: VowelBackness.central,
      rounded: false,
      long: true,
    ),
    Vowel(
      ipa: 'ɒ',
      spelling: 'a',
      example: 'hat',
      exampleIpa: 'hɒt',
      height: VowelHeight.open,
      backness: VowelBackness.back,
      rounded: true,
      long: false,
    ),
  ];

  static const consonants = <Consonant>[
    // Nasals
    Consonant(
      ipa: 'm',
      spelling: 'm',
      example: 'ma',
      exampleIpa: 'mɒ',
      place: ConsonantPlace.bilabial,
      manner: ConsonantManner.nasal,
      voiced: true,
    ),
    Consonant(
      ipa: 'n',
      spelling: 'n',
      example: 'nap',
      exampleIpa: 'nɒp',
      place: ConsonantPlace.dental,
      manner: ConsonantManner.nasal,
      voiced: true,
    ),
    Consonant(
      ipa: 'ɲ',
      spelling: 'ny',
      example: 'nyár',
      exampleIpa: 'ɲaːr',
      place: ConsonantPlace.palatal,
      manner: ConsonantManner.nasal,
      voiced: true,
    ),
    // Plosives
    Consonant(
      ipa: 'p',
      spelling: 'p',
      example: 'pap',
      exampleIpa: 'pɒp',
      place: ConsonantPlace.bilabial,
      manner: ConsonantManner.plosive,
      voiced: false,
    ),
    Consonant(
      ipa: 'b',
      spelling: 'b',
      example: 'bab',
      exampleIpa: 'bɒb',
      place: ConsonantPlace.bilabial,
      manner: ConsonantManner.plosive,
      voiced: true,
    ),
    Consonant(
      ipa: 't',
      spelling: 't',
      example: 'tél',
      exampleIpa: 'teːl',
      place: ConsonantPlace.dental,
      manner: ConsonantManner.plosive,
      voiced: false,
    ),
    Consonant(
      ipa: 'd',
      spelling: 'd',
      example: 'dél',
      exampleIpa: 'deːl',
      place: ConsonantPlace.dental,
      manner: ConsonantManner.plosive,
      voiced: true,
    ),
    Consonant(
      ipa: 'c',
      spelling: 'ty',
      example: 'tyúk',
      exampleIpa: 'cuːk',
      place: ConsonantPlace.palatal,
      manner: ConsonantManner.plosive,
      voiced: false,
    ),
    Consonant(
      ipa: 'ɟ',
      spelling: 'gy',
      example: 'gyár',
      exampleIpa: 'ɟaːr',
      place: ConsonantPlace.palatal,
      manner: ConsonantManner.plosive,
      voiced: true,
    ),
    Consonant(
      ipa: 'k',
      spelling: 'k',
      example: 'kép',
      exampleIpa: 'keːp',
      place: ConsonantPlace.velar,
      manner: ConsonantManner.plosive,
      voiced: false,
    ),
    Consonant(
      ipa: 'ɡ',
      spelling: 'g',
      example: 'gép',
      exampleIpa: 'ɡeːp',
      place: ConsonantPlace.velar,
      manner: ConsonantManner.plosive,
      voiced: true,
    ),
    // Affricates
    Consonant(
      ipa: 't͡s',
      spelling: 'c',
      example: 'cél',
      exampleIpa: 't͡seːl',
      place: ConsonantPlace.alveolar,
      manner: ConsonantManner.affricate,
      voiced: false,
    ),
    Consonant(
      ipa: 'd͡z',
      spelling: 'dz',
      example: 'edz',
      exampleIpa: 'ɛd͡z',
      place: ConsonantPlace.alveolar,
      manner: ConsonantManner.affricate,
      voiced: true,
    ),
    Consonant(
      ipa: 't͡ʃ',
      spelling: 'cs',
      example: 'csak',
      exampleIpa: 't͡ʃɒk',
      place: ConsonantPlace.postalveolar,
      manner: ConsonantManner.affricate,
      voiced: false,
    ),
    Consonant(
      ipa: 'd͡ʒ',
      spelling: 'dzs',
      example: 'dzsem',
      exampleIpa: 'd͡ʒɛm',
      place: ConsonantPlace.postalveolar,
      manner: ConsonantManner.affricate,
      voiced: true,
    ),
    // Fricatives
    Consonant(
      ipa: 'f',
      spelling: 'f',
      example: 'fa',
      exampleIpa: 'fɒ',
      place: ConsonantPlace.labiodental,
      manner: ConsonantManner.fricative,
      voiced: false,
    ),
    Consonant(
      ipa: 'v',
      spelling: 'v',
      example: 'vár',
      exampleIpa: 'vaːr',
      place: ConsonantPlace.labiodental,
      manner: ConsonantManner.fricative,
      voiced: true,
    ),
    Consonant(
      ipa: 's',
      spelling: 'sz',
      example: 'szó',
      exampleIpa: 'soː',
      place: ConsonantPlace.alveolar,
      manner: ConsonantManner.fricative,
      voiced: false,
    ),
    Consonant(
      ipa: 'z',
      spelling: 'z',
      example: 'zöld',
      exampleIpa: 'zøld',
      place: ConsonantPlace.alveolar,
      manner: ConsonantManner.fricative,
      voiced: true,
    ),
    Consonant(
      ipa: 'ʃ',
      spelling: 's',
      example: 'só',
      exampleIpa: 'ʃoː',
      place: ConsonantPlace.postalveolar,
      manner: ConsonantManner.fricative,
      voiced: false,
    ),
    Consonant(
      ipa: 'ʒ',
      spelling: 'zs',
      example: 'zseb',
      exampleIpa: 'ʒɛb',
      place: ConsonantPlace.postalveolar,
      manner: ConsonantManner.fricative,
      voiced: true,
    ),
    Consonant(
      ipa: 'h',
      spelling: 'h',
      example: 'hó',
      exampleIpa: 'hoː',
      place: ConsonantPlace.glottal,
      manner: ConsonantManner.fricative,
      voiced: false,
    ),
    // Trill, lateral, approximant
    Consonant(
      ipa: 'r',
      spelling: 'r',
      example: 'rák',
      exampleIpa: 'raːk',
      place: ConsonantPlace.alveolar,
      manner: ConsonantManner.trill,
      voiced: true,
    ),
    Consonant(
      ipa: 'l',
      spelling: 'l',
      example: 'ló',
      exampleIpa: 'loː',
      place: ConsonantPlace.alveolar,
      manner: ConsonantManner.lateral,
      voiced: true,
    ),
    Consonant(
      ipa: 'j',
      spelling: 'j, ly',
      example: 'jó',
      exampleIpa: 'joː',
      place: ConsonantPlace.palatal,
      manner: ConsonantManner.approximant,
      voiced: true,
    ),
  ];

  /// The vowels at one point of the vowel chart: a short and long pair, one
  /// vowel, or nothing.
  static List<Vowel> vowelsAt(
    VowelHeight height,
    VowelBackness backness, {
    required bool rounded,
  }) =>
      [
        for (final vowel in vowels)
          if (vowel.height == height &&
              vowel.backness == backness &&
              vowel.rounded == rounded)
            vowel,
      ];

  /// The consonants in one cell of the consonant chart: a voiceless and voiced
  /// pair, one consonant, or nothing.
  static List<Consonant> consonantsAt(
    ConsonantColumn column,
    ConsonantManner manner,
  ) =>
      [
        for (final consonant in consonants)
          if (consonant.place.column == column && consonant.manner == manner)
            consonant,
      ];
}
