/// فئات لوح التواصل.
enum AacCategory { basics, food, feelings, actions, places, mine }

/// رمز تواصل (إيموجي + تسمية ثنائية اللغة).
class AacSymbol {
  final String id;
  final String labelAr;
  final String labelEn;
  final String emoji;
  final AacCategory category;

  const AacSymbol({
    required this.id,
    required this.labelAr,
    required this.labelEn,
    required this.emoji,
    required this.category,
  });

  /// التسمية حسب اللغة الحالية.
  String label(String langCode) => langCode == 'en' ? labelEn : labelAr;
}
