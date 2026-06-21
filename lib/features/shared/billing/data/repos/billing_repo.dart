import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/networking/api_constants.dart';
import '../../../../../core/networking/api_error_model.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../core/networking/api_service.dart';
import '../models/billing_models.dart';

/// مستودع الاشتراكات والفوترة — mock + ربط API حقيقي خلف الفلاج.
class BillingRepo {
  final ApiService _api;
  BillingRepo({ApiService? api}) : _api = api ?? ApiService();

  /// الباقات المتاحة + الاشتراك الحالي + الفواتير (نداء واحد مُجمَّع في الـ mock).
  Future<ApiResult<List<SubscriptionPlan>>> getPlans() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(_plans);
      }
      return ApiService.executeApi<List<SubscriptionPlan>>(
        () => _api.get(ApiConstants.subscribe),
        parser: (data) => (data as List)
            .map((e) => SubscriptionPlan.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// الاشتراك الحالي (أو null).
  Future<ApiResult<Subscription?>> getCurrent() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return const ApiResult.success(_current);
      }
      return ApiService.executeApi<Subscription?>(
        () => _api.get('${ApiConstants.me}/subscription'),
        parser: (data) => data == null
            ? null
            : Subscription.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// فواتير المستخدم.
  Future<ApiResult<List<BillingInvoice>>> getInvoices() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        return const ApiResult.success(_invoices);
      }
      return ApiService.executeApi<List<BillingInvoice>>(
        () => _api.get(ApiConstants.invoices),
        parser: (data) => (data as List)
            .map((e) => BillingInvoice.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// الاشتراك في باقة.
  Future<ApiResult<Subscription>> subscribe(String planId) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        final plan = _plans.firstWhere((p) => p.id == planId, orElse: () => _plans.first);
        return ApiResult.success(
          Subscription(
            planId: plan.id,
            planName: plan.name,
            active: true,
            renewsAtLabel: '2026/07/21',
          ),
        );
      }
      return ApiService.executeApi<Subscription>(
        () => _api.post(ApiConstants.subscribe, data: {'plan_id': planId}),
        parser: (data) =>
            Subscription.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  // ----------------------- بيانات mock -----------------------

  static const _plans = [
    SubscriptionPlan(
      id: 'free',
      name: 'المجانية',
      priceMonthly: 0,
      features: ['تمارين محدودة يوميًا', 'تتبّع تقدّم أساسي', 'لوح تواصل (AAC)'],
    ),
    SubscriptionPlan(
      id: 'premium',
      name: 'بريميوم',
      priceMonthly: 49,
      isPopular: true,
      features: [
        'تمارين غير محدودة',
        'تحليل نطق متقدّم بالذكاء الاصطناعي',
        'تقارير تفصيلية وتصدير PDF',
        'محادثة مع الأخصائي',
      ],
    ),
    SubscriptionPlan(
      id: 'family',
      name: 'العائلية',
      priceMonthly: 89,
      features: [
        'كل مزايا بريميوم',
        'حتى ٤ حسابات أطفال',
        'جلسات فيديو مع الأخصائي',
        'دعم ذو أولوية',
      ],
    ),
  ];

  static const _current = Subscription(
    planId: 'free',
    planName: 'المجانية',
    active: true,
    renewsAtLabel: '—',
  );

  static const _invoices = [
    BillingInvoice(
        id: 'inv_1',
        planName: 'بريميوم',
        amount: 49,
        status: PaymentStatus.paid,
        dateLabel: '2026/05/21'),
    BillingInvoice(
        id: 'inv_2',
        planName: 'بريميوم',
        amount: 49,
        status: PaymentStatus.paid,
        dateLabel: '2026/04/21'),
    BillingInvoice(
        id: 'inv_3',
        planName: 'بريميوم',
        amount: 49,
        status: PaymentStatus.pending,
        dateLabel: '2026/06/21'),
  ];
}
