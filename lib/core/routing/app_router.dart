import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/models/user_role.dart';
import '../../features/auth/forgot_password/logic/forgot_password_cubit.dart';
import '../../features/auth/forgot_password/ui/forgot_password.dart';
import '../../features/auth/login/logic/login_cubit.dart';
import '../../features/auth/login/ui/login.dart';
import '../../features/auth/otp/logic/otp_cubit.dart';
import '../../features/auth/otp/ui/otp_verification.dart';
import '../../features/auth/register/logic/register_cubit.dart';
import '../../features/auth/register/ui/register.dart';
import '../../features/auth/reset_password/logic/reset_password_cubit.dart';
import '../../features/auth/reset_password/ui/reset_password.dart';
import '../../features/auth/role_selection/ui/role_selection.dart';
import '../../features/start/language/ui/language_screen.dart';
import '../../features/start/on_boarding/ui/on_boarding.dart';
import '../../features/start/splash/ui/splash.dart';
import '../../features/adult/ui/adult_home.dart';
import '../../features/clinic/ui/clinic_home.dart';
import '../../features/users/patient/main_layout/ui/patient_main_layout.dart';
import '../../features/users/therapist/home/ui/therapist_home.dart';
import '../di/dependancy_injection.dart';
import 'route_builder.dart';
import 'routes.dart';

/// راوتر مركزي واحد — يحقن الـ Cubit المناسب من [getIt] لكل شاشة.
class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final role = args?['role'] as UserRole? ?? UserRole.patient;

    switch (settings.name) {
      case Routes.splash:
        return _route(settings, const SplashScreen());

      case Routes.language:
        return _route(
          settings,
          LanguageScreen(firstLaunch: args?['firstLaunch'] as bool? ?? true),
        );

      case Routes.onBoarding:
        return _route(settings, const OnboardingScreen());

      case Routes.roleSelection:
        return _route(settings, const RoleSelectionScreen());

      case Routes.login:
        return _route(
          settings,
          BlocProvider(
            create: (_) => LoginCubit(getIt(), role: role),
            child: const LoginScreen(),
          ),
        );

      case Routes.register:
        return _route(
          settings,
          BlocProvider(
            create: (_) => RegisterCubit(getIt(), role: role),
            child: const RegisterScreen(),
          ),
        );

      case Routes.forgotPassword:
        return _route(
          settings,
          BlocProvider(
            create: (_) => ForgotPasswordCubit(getIt(), role: role),
            child: const ForgotPasswordScreen(),
          ),
        );

      case Routes.otpVerification:
        return _route(
          settings,
          BlocProvider(
            create: (_) => OtpCubit(
              getIt(),
              identifier: args?['identifier'] as String? ?? '',
              role: role,
            ),
            child: const OtpVerificationScreen(),
          ),
        );

      case Routes.resetPassword:
        return _route(
          settings,
          BlocProvider(
            create: (_) => ResetPasswordCubit(
              getIt(),
              identifier: args?['identifier'] as String? ?? '',
              role: role,
            ),
            child: const ResetPasswordScreen(),
          ),
        );

      case Routes.patientHome:
        return _route(settings, const PatientMainLayout());

      case Routes.adultHome:
        return _route(settings, const AdultHomeScreen());

      case Routes.therapistHome:
        return _route(settings, const TherapistHomeScreen());

      case Routes.clinicHome:
        return _route(settings, const ClinicHomeScreen());

      default:
        return _route(settings, const SplashScreen());
    }
  }

  /// انتقال موحّد + لفّ كل شاشة بـ ValueListenableBuilder لتبديل الثيم الفوري.
  PageRouteBuilder _route(RouteSettings settings, Widget child) {
    return buildAppRoute(child, settings: settings);
  }
}
