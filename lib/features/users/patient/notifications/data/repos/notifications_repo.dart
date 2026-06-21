import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/networking/api_constants.dart';
import '../../../../../../core/networking/api_error_model.dart';
import '../../../../../../core/networking/api_result.dart';
import '../../../../../../core/networking/api_service.dart';
import '../models/notification_item.dart';

/// مستودع الإشعارات — mock + ربط API حقيقي خلف الفلاج.
class NotificationsRepo {
  final ApiService _api;
  NotificationsRepo({ApiService? api}) : _api = api ?? ApiService();

  Future<ApiResult<List<NotificationItem>>> getNotifications() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success([
          NotificationItem(
            id: 'n1',
            type: NotificationType.reminder,
            title: 'جلستك القادمة بعد ساعة',
            body: 'تمارين مخارج الحروف مع د. سارة المهدي',
            timeLabel: 'قبل 5 دقائق',
          ),
          NotificationItem(
            id: 'n2',
            type: NotificationType.achievement,
            title: 'أحسنت! 🎉',
            body: 'أكملت 6 أيام متتالية من التمارين',
            timeLabel: 'قبل ساعتين',
          ),
          NotificationItem(
            id: 'n3',
            type: NotificationType.exercise,
            title: 'تمرين اليوم جاهز',
            body: 'جرّب تمرين نطق الأرقام الجديد',
            timeLabel: 'اليوم',
            read: true,
          ),
          NotificationItem(
            id: 'n4',
            type: NotificationType.motivation,
            title: 'رسالة تحفيزية',
            body: 'كل كلمة تنطقها هي خطوة للأمام 💪',
            timeLabel: 'أمس',
            read: true,
          ),
        ]);
      }
      return ApiService.executeApi<List<NotificationItem>>(
        () => _api.get(ApiConstants.notifications),
        parser: (data) => (data as List)
            .map((e) => NotificationItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }
}
