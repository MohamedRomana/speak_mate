import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/networking/api_result.dart';
import '../data/models/clinic_models.dart';
import '../data/repos/clinic_repo.dart';

enum StaffPhase { loading, ready, error }

/// كيوبت إدارة طاقم أطباء العيادة — عرض/إضافة/حذف. الحالة عدّاد إصدار.
class ClinicStaffCubit extends Cubit<int> {
  final ClinicRepo _repo;
  ClinicStaffCubit(this._repo) : super(0);

  StaffPhase phase = StaffPhase.loading;
  List<ClinicTherapist> therapists = [];
  String? errorMsg;
  bool busy = false;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  Future<void> load() async {
    phase = StaffPhase.loading;
    _emit();
    final res = await _repo.getTherapists();
    if (isClosed) return;
    if (res is Success<List<ClinicTherapist>>) {
      therapists = res.data;
      phase = StaffPhase.ready;
    } else {
      errorMsg = (res as Failure<List<ClinicTherapist>>).error.message;
      phase = StaffPhase.error;
    }
    _emit();
  }

  Future<bool> addTherapist({required String name, required String specialty}) async {
    busy = true;
    _emit();
    final res = await _repo.addTherapist(name: name, specialty: specialty);
    busy = false;
    if (isClosed) return false;
    if (res is Success<ClinicTherapist>) {
      therapists = [...therapists, res.data];
      _emit();
      return true;
    }
    errorMsg = (res as Failure<ClinicTherapist>).error.message;
    _emit();
    return false;
  }

  Future<bool> removeTherapist(String id) async {
    busy = true;
    _emit();
    final res = await _repo.removeTherapist(id);
    busy = false;
    if (isClosed) return false;
    if (res is Success<bool>) {
      therapists = therapists.where((t) => t.id != id).toList();
      _emit();
      return true;
    }
    errorMsg = (res as Failure<bool>).error.message;
    _emit();
    return false;
  }
}
