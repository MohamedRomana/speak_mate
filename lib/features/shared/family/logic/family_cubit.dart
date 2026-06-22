import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/networking/api_result.dart';
import '../data/models/child_profile.dart';
import '../data/repos/family_repo.dart';

enum FamilyPhase { loading, ready, error }

/// كيوبت إدارة الأطفال (الباقة العائلية) — تحميل/إضافة/تبديل الطفل النشط.
class FamilyCubit extends Cubit<int> {
  final FamilyRepo _repo;
  FamilyCubit(this._repo) : super(0);

  FamilyPhase phase = FamilyPhase.loading;
  List<ChildProfile> children = [];
  String activeId = '';
  String? errorMsg;
  bool busy = false;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  bool get canAddMore => children.length < FamilyRepo.maxChildren;

  Future<void> load() async {
    phase = FamilyPhase.loading;
    _emit();
    final res = await _repo.getChildren();
    if (isClosed) return;
    if (res is Success<List<ChildProfile>>) {
      children = res.data;
      // الطفل النشط من الكاش، أو الأول افتراضيًا.
      final cached = CacheHelper.getActiveChildId();
      activeId = children.any((c) => c.id == cached)
          ? cached
          : (children.isNotEmpty ? children.first.id : '');
      phase = FamilyPhase.ready;
    } else {
      errorMsg = (res as Failure<List<ChildProfile>>).error.message;
      phase = FamilyPhase.error;
    }
    _emit();
  }

  /// يبدّل الطفل النشط ويحفظ اختياره (يُحدِّث اسم المستخدم المعروض في اللوحة).
  Future<void> switchActive(ChildProfile child) async {
    if (activeId == child.id) return;
    busy = true;
    _emit();
    final res = await _repo.setActive(child.id);
    busy = false;
    if (isClosed) return;
    if (res is Success<bool>) {
      activeId = child.id;
      await CacheHelper.setActiveChildId(child.id);
      await CacheHelper.setUserName(child.name);
    } else {
      errorMsg = (res as Failure<bool>).error.message;
    }
    _emit();
  }

  Future<bool> addChild({
    required String name,
    required int age,
    required String difficultyType,
    required String emoji,
  }) async {
    busy = true;
    _emit();
    final res = await _repo.addChild(
      name: name,
      age: age,
      difficultyType: difficultyType,
      emoji: emoji,
    );
    busy = false;
    if (isClosed) return false;
    if (res is Success<ChildProfile>) {
      children = [...children, res.data];
      _emit();
      return true;
    }
    errorMsg = (res as Failure<ChildProfile>).error.message;
    _emit();
    return false;
  }
}
