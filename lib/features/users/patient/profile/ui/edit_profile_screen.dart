import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/helper/validators.dart';
import '../../../../../core/logic/action_state.dart';
import '../../../../../core/logic/refresh_emitter.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/satha_field.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../logic/profile_cubit.dart';

/// شاشة تعديل ملف المتدرّب — تشارك نفس [ProfileCubit] مع شاشة الملف.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileCubit _cubit = context.read<ProfileCubit>();

  late final _name = TextEditingController(text: _cubit.profile?.name);
  late final _email = TextEditingController(text: _cubit.profile?.email);
  late final _phone = TextEditingController(text: _cubit.profile?.phone);
  late final _age =
      TextEditingController(text: _cubit.profile?.age?.toString());
  late final _notes = TextEditingController(text: _cubit.profile?.notes);
  late String? _gender = _cubit.profile?.gender;
  late String? _difficulty = _cubit.profile?.difficultyType;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _age.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = _cubit.profile!.copyWith(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      age: int.tryParse(_age.text.trim()),
      gender: _gender,
      difficultyType: _difficulty,
      notes: _notes.text.trim(),
    );
    _cubit.updateProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.w,
              color: AppColors.mainText,
            ),
          ),
        ),
        title: AppText(
          text: LocaleKeys.editProfile.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileCubit, ActionState>(
        listenWhen: (prev, curr) => curr is ActionSuccess || curr is ActionError,
        listener: (context, state) {
          state.whenOrNull(
            // نتجاهل rebuilds الناتجة عن اختيار الأفاتار (#refresh) ونرجع فقط
            // عند حفظ حقيقي ناجح.
            success: (msg) {
              if (msg != null && !isRefreshMessage(msg)) context.pop();
            },
          );
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _AvatarEditor(cubit: _cubit)),
                  SizedBox(height: 24.h),
                  SathaField(
                    controller: _name,
                    label: LocaleKeys.fullName.tr(),
                    prefixIcon: Icons.badge_outlined,
                    validator: Validators.fullName,
                  ),
                  SizedBox(height: 14.h),
                  SathaField(
                    controller: _email,
                    label: LocaleKeys.email.tr(),
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  SizedBox(height: 14.h),
                  SathaField(
                    controller: _phone,
                    label: LocaleKeys.phone.tr(),
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.phone,
                  ),
                  SizedBox(height: 14.h),
                  SathaField(
                    controller: _age,
                    label: LocaleKeys.age.tr(),
                    prefixIcon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 18.h),
                  _FieldLabel(LocaleKeys.gender.tr()),
                  Row(
                    children: [
                      _ChoiceChip(
                        label: LocaleKeys.male.tr(),
                        selected: _gender == 'male',
                        onTap: () => setState(() => _gender = 'male'),
                      ),
                      SizedBox(width: 10.w),
                      _ChoiceChip(
                        label: LocaleKeys.female.tr(),
                        selected: _gender == 'female',
                        onTap: () => setState(() => _gender = 'female'),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  _FieldLabel(LocaleKeys.difficultyType.tr()),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: AppConstants.difficultyTypes
                        .map(
                          (k) => _ChoiceChip(
                            label: k.tr(),
                            selected: _difficulty == k,
                            onTap: () => setState(() => _difficulty = k),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 18.h),
                  _FieldLabel(LocaleKeys.notes.tr()),
                  SathaField(
                    controller: _notes,
                    hint: LocaleKeys.notesHint.tr(),
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  SizedBox(height: 28.h),
                  PrimaryButton(
                    text: LocaleKeys.saveChanges.tr(),
                    loading: state is ActionLoading,
                    icon: Icons.check_rounded,
                    onPressed: _save,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  final ProfileCubit cubit;
  const _AvatarEditor({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ActionState>(
      builder: (context, _) {
        final path = cubit.profile?.avatarPath;
        return GestureDetector(
          onTap: cubit.pickAvatar,
          child: Stack(
            children: [
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softPrimary,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: path != null
                      ? Image.file(
                          File(path),
                          width: 96.w,
                          height: 96.w,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: 48.w,
                          color: AppColors.primary,
                        ),
                ),
              ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    border: Border.all(color: AppColors.scaffoldBg, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 15.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 10.h),
      child: AppText(
        text: text,
        size: 13.sp,
        family: FontFamily.tajawalMedium,
        color: AppColors.mainText,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: AppText(
          text: label,
          size: 13.sp,
          family: FontFamily.tajawalMedium,
          color: selected ? Colors.white : AppColors.mainText,
        ),
      ),
    );
  }
}
