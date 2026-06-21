import '../../../../core/constants/app_constants.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/networking/api_service.dart';
import '../models/therapist_patient.dart';

/// مستودع وحدة الأخصائي — mock + ربط API حقيقي خلف الفلاج.
class TherapistRepo {
  final ApiService _api;
  TherapistRepo({ApiService? api}) : _api = api ?? ApiService();

  int get totalPatients => _patients.length;
  int get activeThisWeek => 5;
  int get avgProgress => 62;

  Future<ApiResult<List<TherapistPatient>>> getPatients() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(_patients);
      }
      return ApiService.executeApi<List<TherapistPatient>>(
        () => _api.get(ApiConstants.patients),
        parser: (data) => (data as List)
            .map((e) => TherapistPatient.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  static const List<TherapistPatient> _patients = [
    TherapistPatient(
      id: 'p1',
      name: 'أحمد محمد',
      age: 8,
      condition: PatientCondition.child,
      progress: 78,
      accuracy: 82,
      lastActive: 'اليوم',
      accuracySeries: [55, 60, 68, 72, 78, 80, 82],
      weakSounds: [WeakSoundStat('ر', 0.62), WeakSoundStat('س', 0.4), WeakSoundStat('ش', 0.28)],
      recordings: [
        PatientRecording(id: 'r1', title: 'تمرين حرف الراء', durationSeconds: 47, accuracy: 80, dateLabel: '2026/06/15'),
        PatientRecording(id: 'r2', title: 'قراءة جملة', durationSeconds: 132, accuracy: 88, dateLabel: '2026/06/13'),
      ],
    ),
    TherapistPatient(
      id: 'p2',
      name: 'سارة علي',
      age: 6,
      condition: PatientCondition.child,
      progress: 45,
      accuracy: 64,
      lastActive: 'أمس',
      accuracySeries: [40, 44, 48, 52, 58, 60, 64],
      weakSounds: [WeakSoundStat('ك', 0.55), WeakSoundStat('ق', 0.33)],
      recordings: [
        PatientRecording(id: 'r3', title: 'نطق الأرقام', durationSeconds: 65, accuracy: 62, dateLabel: '2026/06/14'),
      ],
    ),
    TherapistPatient(
      id: 'p3',
      name: 'خالد عبدالله',
      age: 54,
      condition: PatientCondition.adult,
      progress: 60,
      accuracy: 71,
      lastActive: 'قبل يومين',
      accuracySeries: [50, 55, 58, 62, 66, 68, 71],
      weakSounds: [WeakSoundStat('ث', 0.48), WeakSoundStat('ذ', 0.3)],
      recordings: [
        PatientRecording(id: 'r4', title: 'كلام بطيء - جمل', durationSeconds: 95, accuracy: 70, dateLabel: '2026/06/12'),
      ],
    ),
    TherapistPatient(
      id: 'p4',
      name: 'منى حسن',
      age: 47,
      condition: PatientCondition.adult,
      progress: 38,
      accuracy: 55,
      lastActive: 'قبل ٣ أيام',
      accuracySeries: [30, 35, 40, 44, 48, 52, 55],
      weakSounds: [WeakSoundStat('ل', 0.7), WeakSoundStat('ن', 0.25)],
      recordings: [],
    ),
  ];
}
