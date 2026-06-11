import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/theme_x.dart';
import '../../../../core/logic/action_state.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../widgets/auth_back_button.dart';
import '../../widgets/auth_header.dart';
import '../logic/otp_cubit.dart';

/// شاشة إدخال رمز التحقق (OTP) مع عدّاد إعادة الإرسال.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  Timer? _timer;
  int _secondsLeft = AppConstants.otpResendSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsLeft = AppConstants.otpResendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OtpCubit>();
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: BlocConsumer<OtpCubit, ActionState>(
            listener: (context, state) {
              state.whenOrNull(
                success: (_) => context.pushReplacementNamed(
                  Routes.resetPassword,
                  arguments: {
                    'identifier': cubit.identifier,
                    'role': cubit.role,
                  },
                ),
                error: (msg) => showFlashMessage(
                  message: msg == 'otpInvalid'
                      ? LocaleKeys.otpInvalid.tr()
                      : msg,
                  type: FlashMessageType.error,
                  context: context,
                ),
              );
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(children: [AuthBackButton()]),
                    SizedBox(height: 16.h),
                    AuthHeader(
                      title: LocaleKeys.otpTitle.tr(),
                      subtitle:
                          '${LocaleKeys.otpSubtitle.tr()}\n${cubit.identifier}',
                    ),
                    SizedBox(height: 32.h),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      autoFocus: true,
                      animationType: AnimationType.scale,
                      keyboardType: TextInputType.number,
                      cursorColor: AppColors.primary,
                      textStyle: TextStyle(
                        fontSize: 20.sp,
                        color: context.onBrand,
                        fontFamily: FontFamily.tajawalBold,
                      ),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(14.r),
                        fieldHeight: 54.h,
                        fieldWidth: 46.w,
                        borderWidth: 1.4,
                        activeColor: AppColors.primary,
                        selectedColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        activeFillColor: Colors.transparent,
                        inactiveFillColor: Colors.transparent,
                        selectedFillColor: Colors.transparent,
                      ),
                      enableActiveFill: false,
                      onChanged: (v) => cubit.code = v,
                      onCompleted: (v) {
                        cubit.code = v;
                        cubit.verify();
                      },
                    ),
                    SizedBox(height: 8.h),
                    _ResendRow(
                      secondsLeft: _secondsLeft,
                      onResend: () async {
                        final ok = await cubit.resend();
                        if (!mounted || !ok) return;
                        _startCountdown();
                        if (!context.mounted) return;
                        showFlashMessage(
                          message: LocaleKeys.resendCode.tr(),
                          type: FlashMessageType.success,
                          context: context,
                        );
                      },
                    ),
                    SizedBox(height: 28.h),
                    PrimaryButton(
                      text: LocaleKeys.verify.tr(),
                      loading: state is ActionLoading,
                      onPressed: () {
                        if (cubit.code.length < 6) {
                          showFlashMessage(
                            message: LocaleKeys.otpRequired.tr(),
                            type: FlashMessageType.warning,
                            context: context,
                          );
                          return;
                        }
                        cubit.verify();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  final int secondsLeft;
  final VoidCallback onResend;

  const _ResendRow({required this.secondsLeft, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft <= 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.didntReceiveCode.tr(),
          style: TextStyle(fontSize: 13.sp, color: context.onBrandMuted),
        ),
        SizedBox(width: 6.w),
        canResend
            ? TextButton(
                onPressed: onResend,
                child: Text(
                  LocaleKeys.resendCode.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.primary,
                    fontFamily: FontFamily.tajawalBold,
                  ),
                ),
              )
            : Text(
                '${LocaleKeys.resendCodeIn.tr()} $secondsLeft${LocaleKeys.second.tr()}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.onBrand,
                  fontFamily: FontFamily.tajawalMedium,
                ),
              ),
      ],
    );
  }
}
