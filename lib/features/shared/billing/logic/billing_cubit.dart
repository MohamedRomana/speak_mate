import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../data/models/billing_models.dart';
import '../data/repos/billing_repo.dart';

enum BillingPhase { loading, ready, error }

/// كيوبت الاشتراكات والفوترة — يحمّل الباقات + الاشتراك الحالي + الفواتير،
/// ويدعم الاشتراك في باقة. الحالة عدّاد إصدار والبيانات في الحقول.
class BillingCubit extends Cubit<int> {
  final BillingRepo _repo;
  BillingCubit(this._repo) : super(0);

  BillingPhase phase = BillingPhase.loading;
  List<SubscriptionPlan> plans = [];
  Subscription? current;
  List<BillingInvoice> invoices = [];
  String? errorMsg;
  bool subscribing = false;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  Future<void> load() async {
    phase = BillingPhase.loading;
    _emit();
    final plansRes = await _repo.getPlans();
    if (isClosed) return;
    if (plansRes is Failure<List<SubscriptionPlan>>) {
      errorMsg = plansRes.error.message;
      phase = BillingPhase.error;
      _emit();
      return;
    }
    plans = (plansRes as Success<List<SubscriptionPlan>>).data;

    final curRes = await _repo.getCurrent();
    if (isClosed) return;
    current = curRes is Success<Subscription?> ? curRes.data : null;

    final invRes = await _repo.getInvoices();
    if (isClosed) return;
    invoices = invRes is Success<List<BillingInvoice>> ? invRes.data : [];

    phase = BillingPhase.ready;
    _emit();
  }

  bool isCurrent(String planId) => current?.planId == planId;

  /// يشترك في باقة ويحدّث الاشتراك الحالي عند النجاح.
  Future<bool> subscribe(String planId) async {
    subscribing = true;
    _emit();
    final res = await _repo.subscribe(planId);
    subscribing = false;
    if (isClosed) return false;
    if (res is Success<Subscription>) {
      current = res.data;
      _emit();
      return true;
    }
    errorMsg = (res as Failure<Subscription>).error.message;
    _emit();
    return false;
  }
}
