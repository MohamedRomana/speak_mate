/// نوع الموعد: مكالمة فيديو أو حضوري في العيادة.
enum AppointmentType { video, clinic }

extension AppointmentTypeX on AppointmentType {
  String get key => name;
  static AppointmentType fromKey(String? k) =>
      k == 'clinic' ? AppointmentType.clinic : AppointmentType.video;
}

/// حالة الموعد. `pending` = طلب حجز بانتظار تأكيد الأخصائي.
enum AppointmentStatus { pending, scheduled, completed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get key => name;
  static AppointmentStatus fromKey(String? k) =>
      AppointmentStatus.values.firstWhere(
        (e) => e.name == k,
        orElse: () => AppointmentStatus.scheduled,
      );
}

/// أخصائي متاح للحجز معه.
class TherapistOption {
  final String id;
  final String name;
  final String specialty;
  const TherapistOption({
    required this.id,
    required this.name,
    required this.specialty,
  });

  factory TherapistOption.fromJson(Map<String, dynamic> json) => TherapistOption(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        specialty: (json['specialty'] ?? '').toString(),
      );
}

/// موعد جلسة علاجية. يُستخدم من جانب المتدرّب (يهمّه `therapistName`) ومن جانب
/// الأخصائي (يهمّه `patientName`).
class Appointment {
  final String id;
  final String therapistName;
  final String patientName;
  final String specialty;
  final DateTime dateTime;
  final int durationMinutes;
  final AppointmentType type;
  final AppointmentStatus status;

  const Appointment({
    required this.id,
    required this.therapistName,
    required this.specialty,
    required this.dateTime,
    required this.type,
    required this.status,
    this.patientName = '',
    this.durationMinutes = 30,
  });

  bool get isUpcoming =>
      status == AppointmentStatus.scheduled && dateTime.isAfter(DateTime.now());

  bool get isPending => status == AppointmentStatus.pending;

  Appointment copyWith({AppointmentStatus? status}) => Appointment(
        id: id,
        therapistName: therapistName,
        patientName: patientName,
        specialty: specialty,
        dateTime: dateTime,
        durationMinutes: durationMinutes,
        type: type,
        status: status ?? this.status,
      );

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: (json['id'] ?? '').toString(),
        therapistName: (json['therapist_name'] ?? json['therapist'] ?? '').toString(),
        patientName: (json['patient_name'] ?? json['patient'] ?? '').toString(),
        specialty: (json['specialty'] ?? '').toString(),
        dateTime: DateTime.tryParse('${json['date_time'] ?? json['datetime'] ?? ''}') ??
            DateTime.now(),
        durationMinutes: int.tryParse('${json['duration_minutes']}') ?? 30,
        type: AppointmentTypeX.fromKey(json['type']?.toString()),
        status: AppointmentStatusX.fromKey(json['status']?.toString()),
      );
}
