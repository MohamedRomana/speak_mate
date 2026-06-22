import '../../../../core/constants/app_constants.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/networking/api_service.dart';
import '../models/clinic_models.dart';

/// مستودع وحدة العيادة — mock + ربط API حقيقي خلف الفلاج.
class ClinicRepo {
  final ApiService _api;
  ClinicRepo({ApiService? api}) : _api = api ?? ApiService();

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
      return ApiService.executeApi<List<ClinicAppointment>>(
        () => _api.get(ApiConstants.appointments, query: {'scope': 'clinic'}),
        parser: (data) => (data as List)
            .map((e) => ClinicAppointment.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
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

  // ----------------------- طاقم الأطباء -----------------------

  Future<ApiResult<List<ClinicTherapist>>> getTherapists() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(_therapists);
      }
      return ApiService.executeApi<List<ClinicTherapist>>(
        () => _api.get(ApiConstants.patients, query: {'role': 'therapist'}),
        parser: (data) => (data as List)
            .map((e) => ClinicTherapist.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  Future<ApiResult<ClinicTherapist>> addTherapist({
    required String name,
    required String specialty,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return ApiResult.success(ClinicTherapist(
          id: 't_${name.hashCode.abs()}',
          name: name,
          specialty: specialty,
        ));
      }
      return ApiService.executeApi<ClinicTherapist>(
        () => _api.post('clinic/therapists',
            data: {'name': name, 'specialty': specialty}),
        parser: (data) =>
            ClinicTherapist.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  Future<ApiResult<bool>> removeTherapist(String id) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        return const ApiResult.success(true);
      }
      return ApiService.executeApi<bool>(
        () => _api.delete('clinic/therapists/$id'),
        parser: (_) => true,
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  // ----------------------- التقرير المالي -----------------------

  Future<ApiResult<ClinicFinancials>> getFinancials() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(_financials);
      }
      return ApiService.executeApi<ClinicFinancials>(
        () => _api.get('clinic/financials'),
        parser: (data) =>
            ClinicFinancials.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  static const _therapists = [
    ClinicTherapist(id: 't1', name: 'د. سارة المهدي', specialty: 'اضطرابات النطق واللغة', patientsCount: 18, monthlyRevenue: 7200, active: true),
    ClinicTherapist(id: 't2', name: 'د. خالد العتيبي', specialty: 'التأتأة والطلاقة', patientsCount: 12, monthlyRevenue: 5400, active: true),
    ClinicTherapist(id: 't3', name: 'د. ليلى الحربي', specialty: 'تأخر اللغة عند الأطفال', patientsCount: 9, monthlyRevenue: 3850, active: true),
    ClinicTherapist(id: 't4', name: 'د. عمر فؤاد', specialty: 'صعوبات البلع', patientsCount: 6, monthlyRevenue: 2000, active: false),
  ];

  static const _financials = ClinicFinancials(
    totalRevenue: 18450,
    paidAmount: 14200,
    pendingAmount: 4250,
    monthlyRevenue: [11200, 12800, 13500, 15100, 16900, 18450],
    monthLabels: ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'],
    byTherapist: _therapists,
  );
}
