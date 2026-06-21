/// فئات لوح التواصل.
enum AacCategory { basics, food, feelings, actions, places, mine }

extension AacCategoryX on AacCategory {
  String get key => name;
  static AacCategory fromKey(String? k) => AacCategory.values.firstWhere(
        (e) => e.name == k,
        orElse: () => AacCategory.basics,
      );
}

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

  factory AacSymbol.fromJson(Map<String, dynamic> json) => AacSymbol(
        id: (json['id'] ?? '').toString(),
        labelAr: (json['label_ar'] ?? json['label'] ?? '').toString(),
        labelEn: (json['label_en'] ?? json['label'] ?? '').toString(),
        emoji: (json['emoji'] ?? '❓').toString(),
        category: AacCategoryX.fromKey(json['category']?.toString()),
      );
}
