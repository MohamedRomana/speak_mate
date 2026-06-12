import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/networking/api_error_model.dart';
import '../../../../../../core/networking/api_result.dart';
import '../models/aac_symbol.dart';

/// مستودع لوح التواصل — mock.
class AacRepo {
  Future<ApiResult<List<AacSymbol>>> getSymbols() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return const ApiResult.success(_symbols);
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// عبارات سريعة جاهزة للنطق (قوائم رموز).
  List<List<AacSymbol>> get quickPhrases => const [
        [_iWant, _water, _please],
        [_iAm, _happy],
        [_iWant, _help],
      ];

  static const _iWant = AacSymbol(
    id: 'b_want',
    labelAr: 'أريد',
    labelEn: 'I want',
    emoji: '🤲',
    category: AacCategory.basics,
  );
  static const _iAm = AacSymbol(
    id: 'b_iam',
    labelAr: 'أنا',
    labelEn: 'I am',
    emoji: '🙋',
    category: AacCategory.basics,
  );
  static const _please = AacSymbol(
    id: 'b_please',
    labelAr: 'من فضلك',
    labelEn: 'please',
    emoji: '🙏',
    category: AacCategory.basics,
  );
  static const _water = AacSymbol(
    id: 'f_water',
    labelAr: 'ماء',
    labelEn: 'water',
    emoji: '💧',
    category: AacCategory.food,
  );
  static const _happy = AacSymbol(
    id: 'e_happy',
    labelAr: 'سعيد',
    labelEn: 'happy',
    emoji: '😊',
    category: AacCategory.feelings,
  );
  static const _help = AacSymbol(
    id: 'a_help',
    labelAr: 'مساعدة',
    labelEn: 'help',
    emoji: '🆘',
    category: AacCategory.actions,
  );

  static const List<AacSymbol> _symbols = [
    // أساسيات
    _iWant,
    _iAm,
    _please,
    AacSymbol(id: 'b_you', labelAr: 'أنت', labelEn: 'you', emoji: '👉', category: AacCategory.basics),
    AacSymbol(id: 'b_yes', labelAr: 'نعم', labelEn: 'yes', emoji: '✅', category: AacCategory.basics),
    AacSymbol(id: 'b_no', labelAr: 'لا', labelEn: 'no', emoji: '❌', category: AacCategory.basics),
    AacSymbol(id: 'b_thanks', labelAr: 'شكراً', labelEn: 'thanks', emoji: '🙌', category: AacCategory.basics),
    AacSymbol(id: 'b_more', labelAr: 'المزيد', labelEn: 'more', emoji: '➕', category: AacCategory.basics),
    // طعام
    _water,
    AacSymbol(id: 'f_food', labelAr: 'طعام', labelEn: 'food', emoji: '🍽️', category: AacCategory.food),
    AacSymbol(id: 'f_apple', labelAr: 'تفاحة', labelEn: 'apple', emoji: '🍎', category: AacCategory.food),
    AacSymbol(id: 'f_milk', labelAr: 'حليب', labelEn: 'milk', emoji: '🥛', category: AacCategory.food),
    AacSymbol(id: 'f_bread', labelAr: 'خبز', labelEn: 'bread', emoji: '🍞', category: AacCategory.food),
    AacSymbol(id: 'f_juice', labelAr: 'عصير', labelEn: 'juice', emoji: '🧃', category: AacCategory.food),
    // مشاعر
    _happy,
    AacSymbol(id: 'e_sad', labelAr: 'حزين', labelEn: 'sad', emoji: '😢', category: AacCategory.feelings),
    AacSymbol(id: 'e_tired', labelAr: 'متعب', labelEn: 'tired', emoji: '😴', category: AacCategory.feelings),
    AacSymbol(id: 'e_scared', labelAr: 'خائف', labelEn: 'scared', emoji: '😨', category: AacCategory.feelings),
    AacSymbol(id: 'e_angry', labelAr: 'غاضب', labelEn: 'angry', emoji: '😠', category: AacCategory.feelings),
    AacSymbol(id: 'e_love', labelAr: 'أحب', labelEn: 'love', emoji: '❤️', category: AacCategory.feelings),
    // أفعال
    _help,
    AacSymbol(id: 'a_play', labelAr: 'ألعب', labelEn: 'play', emoji: '🧸', category: AacCategory.actions),
    AacSymbol(id: 'a_eat', labelAr: 'آكل', labelEn: 'eat', emoji: '🍴', category: AacCategory.actions),
    AacSymbol(id: 'a_drink', labelAr: 'أشرب', labelEn: 'drink', emoji: '🥤', category: AacCategory.actions),
    AacSymbol(id: 'a_sleep', labelAr: 'أنام', labelEn: 'sleep', emoji: '🛌', category: AacCategory.actions),
    AacSymbol(id: 'a_go', labelAr: 'أذهب', labelEn: 'go', emoji: '🚶', category: AacCategory.actions),
    // أماكن
    AacSymbol(id: 'p_home', labelAr: 'المنزل', labelEn: 'home', emoji: '🏠', category: AacCategory.places),
    AacSymbol(id: 'p_school', labelAr: 'المدرسة', labelEn: 'school', emoji: '🏫', category: AacCategory.places),
    AacSymbol(id: 'p_bath', labelAr: 'الحمّام', labelEn: 'bathroom', emoji: '🚽', category: AacCategory.places),
    AacSymbol(id: 'p_outside', labelAr: 'الخارج', labelEn: 'outside', emoji: '🌳', category: AacCategory.places),
    AacSymbol(id: 'p_park', labelAr: 'الحديقة', labelEn: 'park', emoji: '🛝', category: AacCategory.places),
  ];
}
