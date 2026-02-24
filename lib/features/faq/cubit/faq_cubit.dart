import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/faq/cubit/faq_state.dart';
import 'package:neomoney/features/faq/models/question_answer_model.dart';
import 'package:neomoney/features/faq/repository/faq_repository.dart';

class FaqCubit extends Cubit<FaqState> {
  final FaqRepository _repo;

  FaqCubit(this._repo) : super(const FaqState()) {
    load();
  }

  final TextEditingController controller = TextEditingController();

  List<QuestionAnswerModel> get _all =>
      state.sections.values.expand((l) => l).toList();

  Future<void> load() async {
    emit(state.copyWith(status: UiStatus.loading, clearErrorMessage: true));
    try {
      final sections = await _repo.getQuestionsAnswers();
      emit(state.copyWith(status: UiStatus.success, sections: sections));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }

  void onChanged() {
    final q = controller.text.trim().toLowerCase();
    if (q.isEmpty) {
      emit(state.copyWith(filteredQuestions: const []));
      return;
    }

    final filtered = _all.where((e) {
      return e.question.toLowerCase().contains(q) || e.answer.toLowerCase().contains(q);
    }).toList();

    emit(state.copyWith(filteredQuestions: filtered));
  }

  void onClear() {
    controller.clear();
    emit(state.copyWith(filteredQuestions: const []));
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}