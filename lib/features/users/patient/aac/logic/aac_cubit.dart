import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../core/networking/api_result.dart';
import '../data/models/aac_symbol.dart';
import '../data/repos/aac_repo.dart';

/// كيوبت لوح التواصل — يدير الرموز، الفئة المختارة، الجملة المكوّنة، والنطق (mock).
class AacCubit extends Cubit<ActionState> {
  final AacRepo _repo;
  AacCubit(this._repo) : super(const ActionState.idle());

  List<AacSymbol> _all = [];
  final List<AacSymbol> custom = [];
  AacCategory selected = AacCategory.basics;
  final List<AacSymbol> sentence = [];
  bool speaking = false;

  List<List<AacSymbol>> get quickPhrases => _repo.quickPhrases;

  Future<void> load() async {
    emit(const ActionState.loading());
    final res = await _repo.getSymbols();
    if (isClosed) return;
    if (res is Failure<List<AacSymbol>>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    _all = (res as Success<List<AacSymbol>>).data;
    emit(const ActionState.success());
  }

  /// رموز الفئة الحالية (فئة "رموزي" تعرض المخصّصة).
  List<AacSymbol> get currentSymbols => selected == AacCategory.mine
      ? custom
      : _all.where((s) => s.category == selected).toList();

  void selectCategory(AacCategory cat) {
    selected = cat;
    emit(const ActionState.success());
  }

  void addToSentence(AacSymbol symbol) {
    sentence.add(symbol);
    emit(const ActionState.success());
  }

  void backspace() {
    if (sentence.isNotEmpty) {
      sentence.removeLast();
      emit(const ActionState.success());
    }
  }

  void clearSentence() {
    sentence.clear();
    emit(const ActionState.success());
  }

  Future<void> speak() async {
    if (sentence.isEmpty || speaking) return;
    speaking = true;
    emit(const ActionState.success());
    // محاكاة مدة النطق حسب عدد الكلمات.
    await Future.delayed(Duration(milliseconds: 500 + sentence.length * 550));
    if (isClosed) return;
    speaking = false;
    emit(const ActionState.success());
  }

  Future<void> speakPhrase(List<AacSymbol> phrase) async {
    sentence
      ..clear()
      ..addAll(phrase);
    emit(const ActionState.success());
    await speak();
  }

  void addCustomSymbol(String label, String emoji) {
    custom.add(
      AacSymbol(
        id: 'c_${custom.length}_${label.hashCode}',
        labelAr: label,
        labelEn: label,
        emoji: emoji,
        category: AacCategory.mine,
      ),
    );
    selected = AacCategory.mine;
    emit(const ActionState.success());
  }
}
