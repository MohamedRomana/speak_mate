import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/patient_profile.dart';
import '../data/models/recording_model.dart';
import '../data/repos/profile_repo.dart';

/// كيوبت ملف المتدرّب — تحميل البيانات والتسجيلات، تعديل الملف، رفع الأفاتار
/// والتسجيلات. يحتفظ بالبيانات في fields وتقرؤها الـ UI.
class ProfileCubit extends Cubit<ActionState> {
  final ProfileRepo _repo;
  ProfileCubit(this._repo) : super(const ActionState.idle());

  PatientProfile? profile;
  List<Recording> recordings = [];

  Future<void> load() async {
    emit(const ActionState.loading());
    final profileRes = await _repo.getProfile();
    final recRes = await _repo.getRecordings();
    if (isClosed) return;
    if (profileRes is Failure<PatientProfile>) {
      emit(ActionState.error(profileRes.error.message ?? ''));
      return;
    }
    profile = (profileRes as Success<PatientProfile>).data;
    recordings = recRes.dataOrNull ?? [];
    emit(const ActionState.success());
  }

  Future<void> updateProfile(PatientProfile updated) async {
    emit(const ActionState.loading());
    final res = await _repo.updateProfile(updated);
    if (isClosed) return;
    if (res is Failure<PatientProfile>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    profile = (res as Success<PatientProfile>).data;
    emit(const ActionState.success(LocaleKeys.profileUpdated));
  }

  /// اختيار صورة أفاتار من المعرض وتحديث الملف محليًا.
  Future<void> pickAvatar() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file == null || profile == null || isClosed) return;
    profile = profile!.copyWith(avatarPath: file.path);
    emit(const ActionState.success());
  }

  /// رفع تسجيل صوتي/فيديو عبر منتقي الملفات (mock — يُضاف للقائمة).
  Future<void> addRecording(RecordingType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type == RecordingType.audio ? FileType.audio : FileType.video,
    );
    if (result == null || result.files.isEmpty || isClosed) return;
    final f = result.files.first;
    recordings = [
      Recording(
        id: 'r_${recordings.length + 1}_${f.name.hashCode}',
        type: type,
        title: f.name,
        durationSeconds: 0,
        dateLabel: 'الآن',
        path: f.path,
      ),
      ...recordings,
    ];
    emit(const ActionState.success());
  }

  void deleteRecording(String id) {
    recordings = recordings.where((r) => r.id != id).toList();
    emit(const ActionState.success());
  }
}
