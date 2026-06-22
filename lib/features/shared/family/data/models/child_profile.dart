/// ملف طفل ضمن حساب وليّ الأمر (الباقة العائلية).
class ChildProfile {
  final String id;
  final String name;
  final int age;
  final String emoji;
  final String difficultyType; // مفتاح من AppConstants.difficultyTypes
  final int progress; // 0..100

  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.emoji,
    required this.difficultyType,
    this.progress = 0,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        age: int.tryParse('${json['age']}') ?? 0,
        emoji: (json['emoji'] ?? '🧒').toString(),
        difficultyType: (json['difficulty_type'] ?? 'difficultySpeech').toString(),
        progress: int.tryParse('${json['progress']}') ?? 0,
      );
}
