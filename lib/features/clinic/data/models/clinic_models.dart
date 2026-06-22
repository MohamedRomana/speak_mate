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

/// أخصائي ضمن طاقم العيادة.
class ClinicTherapist {
  final String id;
  final String name;
  final String specialty;
  final int patientsCount;
  final int monthlyRevenue; // إيراد الأخصائي هذا الشهر
  final bool active;

  const ClinicTherapist({
    required this.id,
    required this.name,
    required this.specialty,
    this.patientsCount = 0,
    this.monthlyRevenue = 0,
    this.active = true,
  });

  factory ClinicTherapist.fromJson(Map<String, dynamic> json) => ClinicTherapist(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        specialty: (json['specialty'] ?? '').toString(),
        patientsCount: int.tryParse('${json['patients_count']}') ?? 0,
        monthlyRevenue: int.tryParse('${json['monthly_revenue']}') ?? 0,
        active: json['active'] != false,
      );
}

/// ملخّص مالي للعيادة (تقرير الإيرادات).
class ClinicFinancials {
  final int totalRevenue;
  final int paidAmount;
  final int pendingAmount;
  final List<double> monthlyRevenue; // آخر 6 أشهر
  final List<String> monthLabels;
  final List<ClinicTherapist> byTherapist; // إيراد كل أخصائي

  const ClinicFinancials({
    required this.totalRevenue,
    required this.paidAmount,
    required this.pendingAmount,
    required this.monthlyRevenue,
    required this.monthLabels,
    required this.byTherapist,
  });

  factory ClinicFinancials.fromJson(Map<String, dynamic> json) => ClinicFinancials(
        totalRevenue: int.tryParse('${json['total_revenue']}') ?? 0,
        paidAmount: int.tryParse('${json['paid_amount']}') ?? 0,
        pendingAmount: int.tryParse('${json['pending_amount']}') ?? 0,
        monthlyRevenue: (json['monthly_revenue'] as List? ?? [])
            .map((e) => double.tryParse('$e') ?? 0)
            .toList(),
        monthLabels: (json['month_labels'] as List? ?? []).map((e) => '$e').toList(),
        byTherapist: (json['by_therapist'] as List? ?? [])
            .map((e) => ClinicTherapist.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
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
