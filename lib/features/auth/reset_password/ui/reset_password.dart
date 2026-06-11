import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/validators.dart';
import '../../../../core/logic/action_state.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/password_strength_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../widgets/auth_back_button.dart';
import '../../widgets/auth_header.dart';
import '../logic/reset_password_cubit.dart';

/// شاشة تعيين كلمة مرور جديدة بعد التحقق من الرمز.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResetPasswordCubit>();
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: BlocConsumer<ResetPasswordCubit, ActionState>(
            listener: (context, state) {
              state.whenOrNull(
                success: (_) {
                  showFlashMessage(
                    message: LocaleKeys.passwordResetSuccess.tr(),
                    type: FlashMessageType.success,
                    context: context,
                  );
                  context.pushNamedAndRemoveUntil(
                    Routes.login,
                    arguments: {'role': cubit.role},
                    predicate: (route) => route.settings.name == Routes.roleSelection,
                  );
                },
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
                        title: LocaleKeys.resetTitle.tr(),
                        subtitle: LocaleKeys.resetSubtitle.tr(),
                      ),
                      SizedBox(height: 32.h),
                      _PasswordWithStrength(
                        controller: cubit.passwordController,
                      ),
                      SizedBox(height: 16.h),
                      SathaPasswordField(
                        controller: cubit.confirmController,
                        label: LocaleKeys.confirmPassword.tr(),
                        textInputAction: TextInputAction.done,
                        validator: (v) => Validators.confirmPassword(
                          v,
                          cubit.passwordController.text,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      PrimaryButton(
                        text: LocaleKeys.updatePassword.tr(),
                        loading: state is ActionLoading,
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.submit();
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

class _PasswordWithStrength extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordWithStrength({required this.controller});

  @override
  State<_PasswordWithStrength> createState() => _PasswordWithStrengthState();
}

class _PasswordWithStrengthState extends State<_PasswordWithStrength> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SathaPasswordField(
          controller: widget.controller,
          label: LocaleKeys.newPassword.tr(),
          validator: Validators.password,
          onChanged: (_) => setState(() {}),
        ),
        PasswordStrengthBar(password: widget.controller.text),
      ],
    );
  }
}
