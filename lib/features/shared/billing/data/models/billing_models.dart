/// دورة الاشتراك.
enum BillingCycle { monthly, yearly }

/// حالة الفاتورة.
enum PaymentStatus { paid, pending, failed }

extension PaymentStatusX on PaymentStatus {
  String get key => name;
  static PaymentStatus fromKey(String? k) => PaymentStatus.values.firstWhere(
        (e) => e.name == k,
        orElse: () => PaymentStatus.pending,
      );
}

/// باقة اشتراك.
class SubscriptionPlan {
  final String id;
  final String name;
  final int priceMonthly; // بالعملة المحلية
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceMonthly,
    this.features = const [],
    this.isPopular = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => SubscriptionPlan(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        priceMonthly: int.tryParse('${json['price_monthly'] ?? json['price']}') ?? 0,
        features: (json['features'] as List? ?? []).map((e) => '$e').toList(),
        isPopular: json['is_popular'] == true || json['popular'] == true,
      );
}

/// اشتراك المستخدم الحالي.
class Subscription {
  final String planId;
  final String planName;
  final bool active;
  final String renewsAtLabel;

  const Subscription({
    required this.planId,
    required this.planName,
    required this.active,
    required this.renewsAtLabel,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        planId: (json['plan_id'] ?? '').toString(),
        planName: (json['plan_name'] ?? '').toString(),
        active: json['active'] == true || '${json['status']}' == 'active',
        renewsAtLabel: (json['renews_at'] ?? '').toString(),
      );
}

/// فاتورة.
class BillingInvoice {
  final String id;
  final String planName;
  final int amount;
  final PaymentStatus status;
  final String dateLabel;

  const BillingInvoice({
    required this.id,
    required this.planName,
    required this.amount,
    required this.status,
    required this.dateLabel,
  });

  factory BillingInvoice.fromJson(Map<String, dynamic> json) => BillingInvoice(
        id: (json['id'] ?? '').toString(),
        planName: (json['plan_name'] ?? '').toString(),
        amount: int.tryParse('${json['amount']}') ?? 0,
        status: PaymentStatusX.fromKey(json['status']?.toString()),
        dateLabel: (json['date'] ?? json['date_label'] ?? '').toString(),
      );
}
