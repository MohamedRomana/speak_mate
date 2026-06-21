import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../data/models/appointment.dart';
import '../data/repos/appointments_repo.dart';

enum ApptPhase { loading, ready, error }

/// كيوبت مواعيد المتدرّب — تحميل القائمة + حجز + إلغاء. الحالة عدّاد إصدار.
class AppointmentsCubit extends Cubit<int> {
  final AppointmentsRepo _repo;
  AppointmentsCubit(this._repo) : super(0);

  ApptPhase phase = ApptPhase.loading;
  List<Appointment> items = [];
  String? errorMsg;
  bool busy = false; // أثناء حجز/إلغاء

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  List<Appointment> get upcoming =>
      (items.where((a) => a.isUpcoming).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime)));

  List<Appointment> get past => items
      .where((a) => !a.isUpcoming)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  Future<void> load() async {
    phase = ApptPhase.loading;
    _emit();
    final res = await _repo.getMyAppointments();
    if (isClosed) return;
    if (res is Success<List<Appointment>>) {
      items = res.data;
      phase = ApptPhase.ready;
    } else {
      errorMsg = (res as Failure<List<Appointment>>).error.message;
      phase = ApptPhase.error;
    }
    _emit();
  }

  /// يحجز موعدًا ويضيفه للقائمة محليًا عند النجاح.
  Future<bool> book({
    required TherapistOption therapist,
    required DateTime dateTime,
    required AppointmentType type,
  }) async {
    busy = true;
    _emit();
    final res = await _repo.book(therapist: therapist, dateTime: dateTime, type: type);
    busy = false;
    if (isClosed) return false;
    if (res is Success<Appointment>) {
      items = [...items, res.data];
      _emit();
      return true;
    }
    errorMsg = (res as Failure<Appointment>).error.message;
    _emit();
    return false;
  }

  /// يلغي موعدًا ويحدّث حالته محليًا.
  Future<bool> cancel(String id) async {
    busy = true;
    _emit();
    final res = await _repo.cancel(id);
    busy = false;
    if (isClosed) return false;
    if (res is Success<bool>) {
      items = items
          .map((a) => a.id == id
              ? a.copyWith(status: AppointmentStatus.cancelled)
              : a)
          .toList();
      _emit();
      return true;
    }
    errorMsg = (res as Failure<bool>).error.message;
    _emit();
    return false;
  }
}
