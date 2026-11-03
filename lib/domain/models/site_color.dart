/// Color of a wiki site, chosen by its owner from a fixed palette.
/// Stored and sent by the backend as [name] (e.g. `'green'`).
/// The actual `Color` lives in the UI layer.
enum SiteColor {
  itk,
  purple,
  red,
  orange,
  amber,
  green,
  mint;

  static const fallback = SiteColor.itk;

  /// Unknown or missing keys fall back to [fallback] instead of throwing,
  /// so a color added later on the backend doesn't break older app versions.
  static SiteColor fromKey(String? key) => values.asNameMap()[key] ?? fallback;
}
