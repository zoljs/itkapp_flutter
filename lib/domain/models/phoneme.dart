/// One Hungarian speech sound with its IPA symbol.
abstract class Phoneme {
  const Phoneme({
    required this.ipa,
    required this.spelling,
    required this.example,
    required this.exampleIpa,
  });

  /// IPA symbol without slashes, e.g. `ɛ`.
  final String ipa;

  /// The Hungarian letter(s) that spell it, e.g. `ty`.
  final String spelling;

  /// A Hungarian word that contains the sound.
  final String example;

  /// IPA transcription of [example] without brackets.
  final String exampleIpa;

  /// Hungarian articulatory description, lowercase.
  String get description;
}

/// Tongue height. The order is the row order of the vowel chart.
enum VowelHeight {
  close('zárt'),
  closeMid('félig zárt'),
  openMid('félig nyílt'),
  open('nyílt');

  const VowelHeight(this.label);

  final String label;
}

/// Horizontal tongue position. The order is the left to right order of the
/// vowel chart.
enum VowelBackness {
  front('elöl', 'elöl képzett'),
  central('középen', 'középen képzett'),
  back('hátul', 'hátul képzett');

  const VowelBackness(this.axisLabel, this.label);

  /// Short label above the chart.
  final String axisLabel;

  /// Label used in a description.
  final String label;
}

class Vowel extends Phoneme {
  const Vowel({
    required super.ipa,
    required super.spelling,
    required super.example,
    required super.exampleIpa,
    required this.height,
    required this.backness,
    required this.rounded,
    required this.long,
  });

  final VowelHeight height;
  final VowelBackness backness;
  final bool rounded;
  final bool long;

  @override
  String get description => '${long ? 'hosszú' : 'rövid'}, ${height.label}, '
      '${backness.label}, ${rounded ? 'ajakkerekítéses' : 'ajakréses'} '
      'magánhangzó';
}

/// Column of the consonant chart. Neighbouring places that never share a
/// manner in Hungarian are merged, as usual in Hungarian phonology tables.
enum ConsonantColumn {
  labial('Lab.', 'labiális'),
  dentalAlveolar('Dent./alv.', 'dentális és alveoláris'),
  postalveolar('Posztalv.', 'posztalveoláris'),
  palatal('Pal.', 'palatális'),
  velar('Vel.', 'veláris'),
  glottal('Glott.', 'glottális');

  const ConsonantColumn(this.shortLabel, this.label);

  final String shortLabel;
  final String label;
}

/// Exact place of articulation.
enum ConsonantPlace {
  bilabial('bilabiális', ConsonantColumn.labial),
  labiodental('labiodentális', ConsonantColumn.labial),
  dental('dentális', ConsonantColumn.dentalAlveolar),
  alveolar('alveoláris', ConsonantColumn.dentalAlveolar),
  postalveolar('posztalveoláris', ConsonantColumn.postalveolar),
  palatal('palatális', ConsonantColumn.palatal),
  velar('veláris', ConsonantColumn.velar),
  glottal('glottális', ConsonantColumn.glottal);

  const ConsonantPlace(this.label, this.column);

  final String label;
  final ConsonantColumn column;
}

/// Manner of articulation. The order is the row order of the consonant chart.
enum ConsonantManner {
  nasal('Nazális', 'nazális'),
  plosive('Zárhang', 'zárhang'),
  affricate('Zár-réshang', 'zár-réshang'),
  fricative('Réshang', 'réshang'),
  trill('Pergőhang', 'pergőhang'),
  lateral('Laterális', 'oldalsó közelítőhang'),
  approximant('Közelítő', 'közelítőhang');

  const ConsonantManner(this.rowLabel, this.noun);

  /// Short label of the chart row.
  final String rowLabel;

  /// Noun used in a description.
  final String noun;
}

class Consonant extends Phoneme {
  const Consonant({
    required super.ipa,
    required super.spelling,
    required super.example,
    required super.exampleIpa,
    required this.place,
    required this.manner,
    required this.voiced,
  });

  final ConsonantPlace place;
  final ConsonantManner manner;
  final bool voiced;

  @override
  String get description =>
      '${voiced ? 'zöngés' : 'zöngétlen'} ${place.label} ${manner.noun}';
}

/// A chart cell is the list of phonemes at one chart position. Two cells are
/// the same when they start with the same phoneme.
bool isSameCell(List<Phoneme> a, List<Phoneme> b) =>
    a.isNotEmpty && b.isNotEmpty && identical(a.first, b.first);
