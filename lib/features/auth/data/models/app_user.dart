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
