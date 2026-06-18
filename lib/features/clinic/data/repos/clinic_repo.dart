import '../../../../core/constants/app_constants.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../models/clinic_models.dart';

/// مستودع وحدة العيادة — mock.
class ClinicRepo {
  ClinicStats get stats => const ClinicStats(
        patients: 48,
        therapists: 6,
        todayAppointments: 9,
        monthlyRevenue: 18450,
      );

  Future<ApiResult<List<ClinicAppointment>>> getAppointments() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success([
          ClinicAppointment(id: 'a1', patientName: 'أحمد محمد', therapistName: 'د. سارة المهدي', timeLabel: '09:00 ص', status: ApptStatus.scheduled, isVideo: false),
          ClinicAppointment(id: 'a2', patientName: 'سارة علي', therapistName: 'د. خالد العتيبي', timeLabel: '10:30 ص', status: ApptStatus.scheduled, isVideo: true),
          ClinicAppointment(id: 'a3', patientName: 'خالد عبدالله', therapistName: 'د. سارة المهدي', timeLabel: '08:00 ص', status: ApptStatus.completed, isVideo: false),
          ClinicAppointment(id: 'a4', patientName: 'منى حسن', therapistName: 'د. ليلى أحمد', timeLabel: '12:00 م', status: ApptStatus.scheduled, isVideo: true),
          ClinicAppointment(id: 'a5', patientName: 'يوسف سامي', therapistName: 'د. خالد العتيبي', timeLabel: '11:15 ص', status: ApptStatus.cancelled, isVideo: false),
        ]);
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  List<Invoice> get invoices => const [
        Invoice(id: 'i1', patientName: 'أحمد محمد', amount: 350, status: InvoiceStatus.paid, dateLabel: '2026/06/15'),
        Invoice(id: 'i2', patientName: 'سارة علي', amount: 300, status: InvoiceStatus.pending, dateLabel: '2026/06/16'),
        Invoice(id: 'i3', patientName: 'خالد عبدالله', amount: 400, status: InvoiceStatus.paid, dateLabel: '2026/06/14'),
        Invoice(id: 'i4', patientName: 'منى حسن', amount: 350, status: InvoiceStatus.pending, dateLabel: '2026/06/17'),
      ];
}
