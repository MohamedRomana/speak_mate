import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../data/models/appointment.dart';
import '../data/repos/appointments_repo.dart';

enum SchedulePhase { loading, ready, error }

/// كيوبت جدول مواعيد الأخصائي — طلبات قيد الانتظار (تأكيد/رفض) + المؤكَّدة + السابقة.
class TherapistScheduleCubit extends Cubit<int> {
  final AppointmentsRepo _repo;
  TherapistScheduleCubit(this._repo) : super(0);

  SchedulePhase phase = SchedulePhase.loading;
  List<Appointment> items = [];
  String? errorMsg;
  bool busy = false;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  List<Appointment> get pending => items.where((a) => a.isPending).toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<Appointment> get upcoming => items.where((a) => a.isUpcoming).toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<Appointment> get past => items
      .where((a) => !a.isPending && !a.isUpcoming)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  Future<void> load() async {
    phase = SchedulePhase.loading;
    _emit();
    final res = await _repo.getTherapistAppointments();
    if (isClosed) return;
    if (res is Success<List<Appointment>>) {
      items = res.data;
      phase = SchedulePhase.ready;
    } else {
      errorMsg = (res as Failure<List<Appointment>>).error.message;
      phase = SchedulePhase.error;
    }
    _emit();
  }

  Future<bool> confirm(String id) => _update(id, AppointmentStatus.scheduled);
  Future<bool> decline(String id) => _update(id, AppointmentStatus.cancelled);

  Future<bool> _update(String id, AppointmentStatus status) async {
    busy = true;
    _emit();
    final res = await _repo.updateStatus(id, status);
    busy = false;
    if (isClosed) return false;
    if (res is Success<bool>) {
      items = items
          .map((a) => a.id == id ? a.copyWith(status: status) : a)
          .toList();
      _emit();
      return true;
    }
    errorMsg = (res as Failure<bool>).error.message;
    _emit();
    return false;
  }
}
