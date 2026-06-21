/// ملف المتدرّب (mock). لما يجهز الـ API نضيف @JsonSerializable.
class PatientProfile {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final int? age;
  final String? gender; // 'male' / 'female'
  final String? difficultyType; // مفتاح من AppConstants.difficultyTypes
  final String? notes;
  final String? avatarUrl; // رابط شبكة
  final String? avatarPath; // ملف محلي مختار

  const PatientProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.age,
    this.gender,
    this.difficultyType,
    this.notes,
    this.avatarUrl,
    this.avatarPath,
  });

  /// نسبة اكتمال الملف (0..1) حسب الحقول المعبّأة.
  double get completion {
    final fields = [name, email, phone, age?.toString(), gender, difficultyType, notes];
    final filled = fields.where((f) => f != null && f.trim().isNotEmpty).length;
    return filled / fields.length;
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) => PatientProfile(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        age: json['age'] is int ? json['age'] as int : int.tryParse('${json['age']}'),
        gender: json['gender']?.toString(),
        difficultyType: json['difficulty_type']?.toString(),
        notes: json['notes']?.toString(),
        avatarUrl: json['avatar']?.toString() ?? json['avatar_url']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'age': age,
        'gender': gender,
        'difficulty_type': difficultyType,
        'notes': notes,
      };

  PatientProfile copyWith({
    String? name,
    String? email,
    String? phone,
    int? age,
    String? gender,
    String? difficultyType,
    String? notes,
    String? avatarUrl,
    String? avatarPath,
  }) {
    return PatientProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      difficultyType: difficultyType ?? this.difficultyType,
      notes: notes ?? this.notes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
