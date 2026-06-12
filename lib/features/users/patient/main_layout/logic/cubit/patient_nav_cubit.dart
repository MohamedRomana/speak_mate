import 'package:flutter_bloc/flutter_bloc.dart';

/// كيوبت التحكّم في تبويب الشريط السفلي للمتدرّب.
class PatientNavCubit extends Cubit<int> {
  PatientNavCubit() : super(0);

  void select(int index) => emit(index);
}
