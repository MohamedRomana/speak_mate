import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/theme_x.dart';
import '../../../../core/helper/validators.dart';
import '../../../../core/logic/action_state.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/animated_checkbox.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../core/widgets/lang_toggle.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/satha_field.dart';
import '../../../../core/widgets/theme_toggle.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/user_role.dart';
import '../../widgets/auth_back_button.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/social_login_row.dart';
import '../logic/login_cubit.dart';

/// شاشة تسجيل الدخول — تُحقن بـ [LoginCubit] من الراوتر حسب الدور.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    final role = cubit.role;
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: BlocConsumer<LoginCubit, ActionState>(
            listener: (context, state) {
              state.whenOrNull(
                success: (msg) {
                  showFlashMessage(
                    message: (msg ?? LocaleKeys.loginSuccess).tr(),
                    type: FlashMessageType.success,
                    context: context,
                  );
                  final home = role.isTherapist
                      ? Routes.therapistHome
                      : Routes.patientHome;
                  context.pushNamedAndRemoveUntil(
                    home,
                    predicate: (_) => false,
                  );
                },
                error: (msg) => showFlashMessage(
                  message: _msg(msg),
                  type: FlashMessageType.error,
                  context: context,
                ),
              );
            },
            builder: (context, state) {
              final loading = state is ActionLoading;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                child: Form(
                  key: cubit.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const AuthBackButton(),
                          const Spacer(),
                          const LangToggle(),
                          SizedBox(width: 10.w),
                          const ThemeToggle(),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      AuthHeader(
                        title: LocaleKeys.welcomeBack.tr(),
                        subtitle: (role.isTherapist
                                ? LocaleKeys.therapistLoginDesc
                                : LocaleKeys.patientLoginDesc)
                            .tr(),
                      ),
                      SizedBox(height: 28.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 150),
                        child: SathaField(
                          controller: cubit.identifierController,
                          label: LocaleKeys.emailOrPhone.tr(),
                          hint: LocaleKeys.emailOrPhone.tr(),
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.phoneOrEmail,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 220),
                        child: SathaPasswordField(
                          controller: cubit.passwordController,
                          label: LocaleKeys.password.tr(),
                          hint: LocaleKeys.password.tr(),
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _RememberForgotRow(role: role),
                      SizedBox(height: 24.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 300),
                        child: PrimaryButton(
                          text: LocaleKeys.login.tr(),
                          loading: loading,
                          onPressed: () {
                            if (cubit.formKey.currentState!.validate()) {
                              cubit.login();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),
                      OrDivider(text: LocaleKeys.orContinueWith.tr()),
                      SizedBox(height: 20.h),
                      SocialLoginRow(
                        onProvider: loading ? (_) {} : cubit.socialLogin,
                      ),
                      SizedBox(height: 28.h),
                      _RegisterLink(role: role),
                      SizedBox(height: 12.h),
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

  String _msg(String key) {
    // مفاتيح معروفة تُترجم، وإلا تُعرض كما هي.
    const known = {
      'otpInvalid': LocaleKeys.otpInvalid,
    };
    return known.containsKey(key) ? known[key]!.tr() : key;
  }
}

class _RememberForgotRow extends StatefulWidget {
  final UserRole role;
  const _RememberForgotRow({required this.role});

  @override
  State<_RememberForgotRow> createState() => _RememberForgotRowState();
}

class _RememberForgotRowState extends State<_RememberForgotRow> {
  late bool _remember = CacheHelper.getRememberMe();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedCheckbox(
          value: _remember,
          onChanged: (v) {
            setState(() => _remember = v);
            cubit.rememberMe = v;
          },
          label: Text(
            LocaleKeys.rememberMe.tr(),
            style: TextStyle(fontSize: 13.sp, color: context.onBrand),
          ),
        ),
        TextButton(
          onPressed: () => context.pushNamed(
            Routes.forgotPassword,
            arguments: {'role': widget.role},
          ),
          child: Text(
            LocaleKeys.forgotPassword.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.primary,
              fontFamily: FontFamily.tajawalMedium,
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterLink extends StatelessWidget {
  final UserRole role;
  const _RegisterLink({required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.dontHaveAccount.tr(),
          style: TextStyle(fontSize: 13.sp, color: context.onBrandMuted),
        ),
        TextButton(
          onPressed: () => context.pushNamed(
            Routes.register,
            arguments: {'role': role},
          ),
          child: Text(
            LocaleKeys.signUp.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primary,
              fontFamily: FontFamily.tajawalBold,
            ),
          ),
        ),
      ],
    );
  }
}
