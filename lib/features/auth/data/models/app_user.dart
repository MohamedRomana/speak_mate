import 'user_role.dart';

/// نموذج المستخدم في SpeakMate (mock — بسيط بدون json حاليًا).
/// لما يجهز الـ API نضيف `@JsonSerializable` + fromJson/toJson.
class AppUser {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final UserRole role;

  // خاص بالمتدرّب
  final int? age;
  final String? difficultyType; // مفتاح من AppConstants.difficultyTypes
  final String? avatarUrl;

  // خاص بالأخصائي
  final String? specialty;
  final String? licenseNumber;
  final int? yearsOfExperience;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.age,
    this.difficultyType,
    this.avatarUrl,
    this.specialty,
    this.licenseNumber,
    this.yearsOfExperience,
  });

  /// تفكيك مستخدم من رد الـ API الحقيقي (داخل `data`).
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: UserRoleX.fromKey(json['role']?.toString()),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      age: json['age'] is int ? json['age'] as int : int.tryParse('${json['age']}'),
      difficultyType: json['difficulty_type']?.toString(),
      avatarUrl: json['avatar']?.toString() ?? json['avatar_url']?.toString(),
      specialty: json['specialty']?.toString(),
      licenseNumber: json['license_number']?.toString(),
      yearsOfExperience: json['years_of_experience'] is int
          ? json['years_of_experience'] as int
          : int.tryParse('${json['years_of_experience']}'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.key,
        'email': email,
        'phone': phone,
        'age': age,
        'difficulty_type': difficultyType,
        'avatar': avatarUrl,
        'specialty': specialty,
        'license_number': licenseNumber,
        'years_of_experience': yearsOfExperience,
      };

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    int? age,
    String? difficultyType,
    String? avatarUrl,
    String? specialty,
    String? licenseNumber,
    int? yearsOfExperience,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      age: age ?? this.age,
      difficultyType: difficultyType ?? this.difficultyType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }
}
