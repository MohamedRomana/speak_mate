enum ApptStatus { scheduled, completed, cancelled }

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
