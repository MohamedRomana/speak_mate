import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/networking/api_constants.dart';
import '../../../../../core/networking/api_error_model.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../core/networking/api_service.dart';
import '../models/appointment.dart';

/// مستودع المواعيد — عرض/حجز/إلغاء. mock + ربط API حقيقي خلف الفلاج.
class AppointmentsRepo {
  final ApiService _api;
  AppointmentsRepo({ApiService? api}) : _api = api ?? ApiService();

  /// قائمة الأخصائيين المتاحين للحجز.
  Future<ApiResult<List<TherapistOption>>> getTherapists() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return const ApiResult.success(_therapists);
      }
      return ApiService.executeApi<List<TherapistOption>>(
        () => _api.get(ApiConstants.patients, query: {'role': 'therapist'}),
        parser: (data) => (data as List)
            .map((e) => TherapistOption.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// مواعيد المتدرّب.
  Future<ApiResult<List<Appointment>>> getMyAppointments() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return ApiResult.success(_mockList());
      }
      return ApiService.executeApi<List<Appointment>>(
        () => _api.get(ApiConstants.appointments),
        parser: (data) => (data as List)
            .map((e) => Appointment.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// حجز موعد جديد.
  Future<ApiResult<Appointment>> book({
    required TherapistOption therapist,
    required DateTime dateTime,
    required AppointmentType type,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return ApiResult.success(
          Appointment(
            id: 'a_${dateTime.millisecondsSinceEpoch}',
            therapistName: therapist.name,
            specialty: therapist.specialty,
            dateTime: dateTime,
            type: type,
            status: AppointmentStatus.scheduled,
          ),
        );
      }
      return ApiService.executeApi<Appointment>(
        () => _api.post(ApiConstants.appointments, data: {
          'therapist_id': therapist.id,
          'date_time': dateTime.toIso8601String(),
          'type': type.key,
        }),
        parser: (data) =>
            Appointment.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// إلغاء موعد.
  Future<ApiResult<bool>> cancel(String id) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 700));
        return const ApiResult.success(true);
      }
      return ApiService.executeApi<bool>(
        () => _api.put(ApiConstants.appointment(id), data: {'status': 'cancelled'}),
        parser: (_) => true,
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  // ----------------------- بيانات mock -----------------------

  static const _therapists = [
    TherapistOption(id: 't1', name: 'د. سارة المهدي', specialty: 'اضطرابات النطق واللغة'),
    TherapistOption(id: 't2', name: 'د. خالد العتيبي', specialty: 'التأتأة والطلاقة'),
    TherapistOption(id: 't3', name: 'د. ليلى الحربي', specialty: 'تأخر اللغة عند الأطفال'),
  ];

  List<Appointment> _mockList() {
    final now = DateTime.now();
    return [
      Appointment(
        id: 'a1',
        therapistName: 'د. سارة المهدي',
        specialty: 'اضطرابات النطق واللغة',
        dateTime: now.add(const Duration(days: 1, hours: 3)),
        type: AppointmentType.video,
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'a2',
        therapistName: 'د. خالد العتيبي',
        specialty: 'التأتأة والطلاقة',
        dateTime: now.add(const Duration(days: 4)),
        type: AppointmentType.clinic,
        status: AppointmentStatus.scheduled,
      ),
      Appointment(
        id: 'a3',
        therapistName: 'د. سارة المهدي',
        specialty: 'اضطرابات النطق واللغة',
        dateTime: now.subtract(const Duration(days: 3)),
        type: AppointmentType.video,
        status: AppointmentStatus.completed,
      ),
    ];
  }
}
