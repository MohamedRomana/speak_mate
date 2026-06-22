import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../../../auth/data/models/app_user.dart';
import '../data/repos/account_repo.dart';

enum AccountPhase { loading, ready, error }

/// كيوبت حساب المستخدم الحالي (الأدوار غير الطفل). الحالة عدّاد إصدار.
class AccountCubit extends Cubit<int> {
  final AccountRepo _repo;
  AccountCubit(this._repo) : super(0);

  AccountPhase phase = AccountPhase.loading;
  AppUser? user;
  String? errorMsg;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  Future<void> load() async {
    phase = AccountPhase.loading;
    _emit();
    final res = await _repo.getAccount();
    if (isClosed) return;
    if (res is Success<AppUser>) {
      user = res.data;
      phase = AccountPhase.ready;
    } else {
      errorMsg = (res as Failure<AppUser>).error.message;
      phase = AccountPhase.error;
    }
    _emit();
  }
}
