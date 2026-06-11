import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/theme_x.dart';
import '../../../../core/helper/validators.dart';
import '../../../../core/logic/action_state.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/animated_checkbox.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/password_strength_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/satha_field.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/user_role.dart';
import '../../widgets/auth_back_button.dart';
import '../../widgets/auth_header.dart';
import '../logic/register_cubit.dart';

/// شاشة إنشاء الحساب — تُحقن بـ [RegisterCubit] من الراوتر حسب الدور.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final role = cubit.role;
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: BlocConsumer<RegisterCubit, ActionState>(
            listener: (context, state) {
              state.whenOrNull(
                success: (msg) {
                  showFlashMessage(
                    message: (msg ?? LocaleKeys.registerSuccess).tr(),
                    type: FlashMessageType.success,
                    context: context,
                  );
                  final home = role.isTherapist
                      ? Routes.therapistHome
                      : Routes.patientHome;
                  context.pushNamedAndRemoveUntil(home, predicate: (_) => false);
                },
                error: (msg) => showFlashMessage(
                  message: msg,
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
                      const Row(
                        children: [AuthBackButton()],
                      ),
                      SizedBox(height: 8.h),
                      AuthHeader(
                        showLogo: false,
                        title: LocaleKeys.createAccount.tr(),
                        subtitle: (role.isTherapist
                                ? LocaleKeys.therapistRegisterDesc
                                : LocaleKeys.patientRegisterDesc)
                            .tr(),
                      ),
                      SizedBox(height: 24.h),
                      SathaField(
                        controller: cubit.nameController,
                        label: LocaleKeys.fullName.tr(),
                        prefixIcon: Icons.badge_outlined,
                        validator: Validators.fullName,
                      ),
                      SizedBox(height: 16.h),
                      SathaField(
                        controller: cubit.identifierController,
                        label: LocaleKeys.emailOrPhone.tr(),
                        prefixIcon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.phoneOrEmail,
                      ),
                      SizedBox(height: 16.h),
                      if (role.isPatient) ..._patientFields(cubit),
                      if (role.isTherapist) ..._therapistFields(cubit),
                      _PasswordWithStrength(controller: cubit.passwordController),
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
                      SizedBox(height: 18.h),
                      _TermsRow(
                        agreed: _agreed,
                        onChanged: (v) => setState(() => _agreed = v),
                      ),
                      SizedBox(height: 22.h),
                      PrimaryButton(
                        text: LocaleKeys.signUp.tr(),
                        loading: loading,
                        onPressed: () => _submit(cubit),
                      ),
                      SizedBox(height: 18.h),
                      _LoginLink(role: role),
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

  void _submit(RegisterCubit cubit) {
    if (!cubit.formKey.currentState!.validate()) return;
    if (cubit.role.isPatient && cubit.difficultyType == null) {
      showFlashMessage(
        message: LocaleKeys.fieldRequired.tr(),
        type: FlashMessageType.warning,
        context: context,
      );
      return;
    }
    if (!_agreed) {
      showFlashMessage(
        message: LocaleKeys.bySigningUp.tr(),
        type: FlashMessageType.warning,
        context: context,
      );
      return;
    }
    cubit.register();
  }

  List<Widget> _patientFields(RegisterCubit cubit) {
    return [
      SathaField(
        controller: cubit.ageController,
        label: LocaleKeys.age.tr(),
        prefixIcon: Icons.cake_outlined,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (v) =>
            (v == null || v.isEmpty) ? LocaleKeys.ageRequired.tr() : null,
      ),
      SizedBox(height: 16.h),
      Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: AppConstants.difficultyTypes.map((key) {
          final selected = cubit.difficultyType == key;
          return _DifficultyChip(
            label: key.tr(),
            selected: selected,
            onTap: () => cubit.selectDifficulty(key),
          );
        }).toList(),
      ),
      SizedBox(height: 16.h),
    ];
  }

  List<Widget> _therapistFields(RegisterCubit cubit) {
    return [
      SathaField(
        controller: cubit.specialtyController,
        label: LocaleKeys.specialty.tr(),
        prefixIcon: Icons.school_outlined,
        validator: Validators.required,
      ),
      SizedBox(height: 16.h),
      SathaField(
        controller: cubit.licenseController,
        label: LocaleKeys.licenseNumber.tr(),
        prefixIcon: Icons.verified_outlined,
        validator: Validators.required,
      ),
      SizedBox(height: 8.h),
      Padding(
        padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 8.h),
        child: Text(
          LocaleKeys.verificationNote.tr(),
          style: TextStyle(fontSize: 11.sp, color: context.onBrandMuted),
        ),
      ),
      SizedBox(height: 8.h),
    ];
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
          label: LocaleKeys.password.tr(),
          validator: Validators.password,
          onChanged: (_) => setState(() {}),
        ),
        PasswordStrengthBar(password: widget.controller.text),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(14.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (context.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: selected ? Colors.white : context.onBrand,
            fontFamily: FontFamily.tajawalMedium,
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool> onChanged;
  const _TermsRow({required this.agreed, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedCheckbox(
      value: agreed,
      onChanged: onChanged,
      label: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 12.sp, color: context.onBrandMuted),
          children: [
            TextSpan(text: '${LocaleKeys.bySigningUp.tr()} '),
            TextSpan(
              text: LocaleKeys.termsOfService.tr(),
              style: const TextStyle(color: AppColors.primary),
            ),
            TextSpan(text: ' ${LocaleKeys.and.tr()} '),
            TextSpan(
              text: LocaleKeys.privacyPolicy.tr(),
              style: const TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginLink extends StatelessWidget {
  final UserRole role;
  const _LoginLink({required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.alreadyHaveAccount.tr(),
          style: TextStyle(fontSize: 13.sp, color: context.onBrandMuted),
        ),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            LocaleKeys.signIn.tr(),
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

