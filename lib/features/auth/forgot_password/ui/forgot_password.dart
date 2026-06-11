import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/validators.dart';
import '../../../../core/logic/action_state.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/satha_field.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_back_button.dart';
import '../logic/forgot_password_cubit.dart';

/// شاشة استعادة كلمة المرور — تُرسل رمز التحقق ثم تنتقل لشاشة OTP.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ForgotPasswordCubit>();
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: BlocConsumer<ForgotPasswordCubit, ActionState>(
            listener: (context, state) {
              state.whenOrNull(
                success: (_) => context.pushNamed(
                  Routes.otpVerification,
                  arguments: {
                    'identifier': cubit.identifier,
                    'role': cubit.role,
                  },
                ),
                error: (msg) => showFlashMessage(
                  message: msg,
                  type: FlashMessageType.error,
                  context: context,
                ),
              );
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(children: [AuthBackButton()]),
                      SizedBox(height: 16.h),
                      AuthHeader(
                        title: LocaleKeys.forgotTitle.tr(),
                        subtitle: LocaleKeys.forgotSubtitle.tr(),
                      ),
                      SizedBox(height: 32.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 150),
                        child: SathaField(
                          controller: cubit.identifierController,
                          label: LocaleKeys.emailOrPhone.tr(),
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: Validators.phoneOrEmail,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      PrimaryButton(
                        text: LocaleKeys.sendCode.tr(),
                        loading: state is ActionLoading,
                        icon: Icons.send_rounded,
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.sendCode();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
