import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/networking/api_result.dart';
import '../data/models/therapist_patient.dart';
import '../data/repos/therapist_repo.dart';

/// فلتر حالة المريض.
enum PatientFilter { all, child, adult }

/// كيوبت لوحة الأخصائي — تحميل المرضى + بحث + فلترة. الحالة عدّاد إصدار.
class TherapistHomeCubit extends Cubit<int> {
  final TherapistRepo _repo;
  TherapistHomeCubit(this._repo) : super(0);

  List<TherapistPatient> _all = [];
  String query = '';
  PatientFilter filter = PatientFilter.all;
  bool loading = true;

  int get totalPatients => _repo.totalPatients;
  int get activeThisWeek => _repo.activeThisWeek;
  int get avgProgress => _repo.avgProgress;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  Future<void> load() async {
    loading = true;
    _emit();
    final res = await _repo.getPatients();
    if (isClosed) return;
    if (res is Success<List<TherapistPatient>>) _all = res.data;
    loading = false;
    _emit();
  }

  /// المرضى بعد تطبيق البحث والفلتر.
  List<TherapistPatient> get patients {
    return _all.where((p) {
      final byFilter = switch (filter) {
        PatientFilter.all => true,
        PatientFilter.child => p.condition == PatientCondition.child,
        PatientFilter.adult => p.condition == PatientCondition.adult,
      };
      final byQuery = query.isEmpty || p.name.contains(query.trim());
      return byFilter && byQuery;
    }).toList();
  }

  void setQuery(String q) {
    query = q;
    _emit();
  }

  void setFilter(PatientFilter f) {
    filter = f;
    _emit();
  }
}
