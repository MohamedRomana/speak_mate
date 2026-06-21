enum ApptStatus { scheduled, completed, cancelled }

extension ApptStatusX on ApptStatus {
  static ApptStatus fromKey(String? k) => ApptStatus.values.firstWhere(
        (e) => e.name == k,
        orElse: () => ApptStatus.scheduled,
      );
}

enum InvoiceStatus { paid, pending }

/// موعد في العيادة.
class ClinicAppointment {
  final String id;
  final String patientName;
  final String therapistName;
  final String timeLabel;
  final ApptStatus status;
  final bool isVideo;

  const ClinicAppointment({
    required this.id,
    required this.patientName,
    required this.therapistName,
    required this.timeLabel,
    required this.status,
    this.isVideo = false,
  });

  factory ClinicAppointment.fromJson(Map<String, dynamic> json) => ClinicAppointment(
        id: (json['id'] ?? '').toString(),
        patientName: (json['patient_name'] ?? json['patient'] ?? '').toString(),
        therapistName: (json['therapist_name'] ?? json['therapist'] ?? '').toString(),
        timeLabel: (json['time_label'] ?? json['time'] ?? '').toString(),
        status: ApptStatusX.fromKey(json['status']?.toString()),
        isVideo: json['is_video'] == true || '${json['type']}' == 'video',
      );
}

/// فاتورة.
class Invoice {
  final String id;
  final String patientName;
  final int amount;
  final InvoiceStatus status;
  final String dateLabel;

  const Invoice({
    required this.id,
    required this.patientName,
    required this.amount,
    required this.status,
    required this.dateLabel,
  });
}

/// إحصائيات العيادة.
class ClinicStats {
  final int patients;
  final int therapists;
  final int todayAppointments;
  final int monthlyRevenue;

  const ClinicStats({
    required this.patients,
    required this.therapists,
    required this.todayAppointments,
    required this.monthlyRevenue,
  });
}
