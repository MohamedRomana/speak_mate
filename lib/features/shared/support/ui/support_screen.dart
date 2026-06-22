import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/satha_field.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/repos/support_repo.dart';

/// شاشة الدعم والمساعدة — تواصل + أسئلة شائعة + الإبلاغ عن مشكلة.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _email = 'support@voicebridge.ai';
  static const _phone = '+966500000000';

  // أسئلة شائعة ثنائية اللغة (محتوى ثابت).
  static const _faq = [
    (
      'كيف أبدأ جلسة تمرين؟',
      'من اللوحة الرئيسية اختر "التمارين" ثم الفئة المناسبة واضغط ابدأ.',
      'How do I start an exercise session?',
      'From the home dashboard open "Exercises", pick a category, then tap start.',
    ),
    (
      'كيف يعمل تحليل النطق؟',
      'نسجّل صوتك ونحلّله على مستوى الأصوات (الفونيمات) لنحدّد الصوت محلّ التحسين.',
      'How does speech analysis work?',
      'We record your voice and analyze it phoneme-by-phoneme to pinpoint the sound to improve.',
    ),
    (
      'كيف أحجز موعدًا مع أخصائي؟',
      'من "مواعيدي" اضغط "حجز موعد"، اختر الأخصائي والتاريخ ونوع الجلسة.',
      'How do I book an appointment?',
      'In "My appointments" tap "Book appointment", choose a therapist, date and session type.',
    ),
    (
      'هل يمكنني استخدام التطبيق دون إنترنت؟',
      'نعم، تحليل النطق يعمل على الجهاز، وتُزامن بياناتك عند عودة الاتصال.',
      'Can I use the app offline?',
      'Yes, speech analysis runs on-device and your data syncs once you are back online.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ar = context.locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            flipX: ar,
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18.w, color: AppColors.mainText),
          ),
        ),
        title: AppText(
          text: LocaleKeys.support.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              text: LocaleKeys.contactUs.tr(),
              size: 15.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _ContactButton(
                    icon: Icons.call_rounded,
                    label: LocaleKeys.callUs.tr(),
                    onTap: () => _launch('tel:$_phone'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ContactButton(
                    icon: Icons.email_rounded,
                    label: LocaleKeys.emailUs.tr(),
                    onTap: () => _launch('mailto:$_email'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            AppText(
              text: LocaleKeys.faqTitle.tr(),
              size: 15.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
            ),
            SizedBox(height: 10.h),
            ..._faq.map((f) => _FaqItem(
                  question: ar ? f.$1 : f.$3,
                  answer: ar ? f.$2 : f.$4,
                )),
            SizedBox(height: 22.h),
            PrimaryButton(
              text: LocaleKeys.reportProblem.tr(),
              icon: Icons.report_problem_outlined,
              onPressed: () => _showReportSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String uri) async {
    final u = Uri.parse(uri);
    if (await canLaunchUrl(u)) await launchUrl(u);
  }

  void _showReportSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => const _ReportSheet(),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.w, color: AppColors.primary),
            SizedBox(height: 6.h),
            AppText(
              text: label,
              size: 13.sp,
              family: FontFamily.tajawalMedium,
              color: AppColors.mainText,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w),
          childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.secondaryText,
          title: AppText(
            text: question,
            size: 13.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.mainText,
            lines: 2,
          ),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppText(
                text: answer,
                size: 12.sp,
                lines: 5,
                overflow: TextOverflow.visible,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _controller = TextEditingController();
  final _repo = getIt<SupportRepo>();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final res = await _repo.submitReport(_controller.text.trim());
    if (!mounted) return;
    setState(() => _sending = false);
    Navigator.of(context).pop();
    showFlashMessage(
      message: res is Success<bool>
          ? LocaleKeys.problemSubmitted.tr()
          : LocaleKeys.somethingWentWrong.tr(),
      type: res is Success<bool> ? FlashMessageType.success : FlashMessageType.error,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          AppText(
            text: LocaleKeys.reportProblem.tr(),
            size: 16.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.mainText,
          ),
          SizedBox(height: 14.h),
          SathaField(
            controller: _controller,
            hint: LocaleKeys.reportHint.tr(),
            keyboardType: TextInputType.multiline,
            maxLines: 5,
          ),
          SizedBox(height: 18.h),
          PrimaryButton(
            text: LocaleKeys.sendReport.tr(),
            icon: Icons.send_rounded,
            loading: _sending,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
