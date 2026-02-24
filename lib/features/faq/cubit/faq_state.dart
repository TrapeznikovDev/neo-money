import 'package:equatable/equatable.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/faq/models/question_answer_model.dart';

class FaqState extends Equatable implements UiState {
  @override
  final UiStatus status;

  @override
  final String? errorMessage;

  final Map<String, List<QuestionAnswerModel>> sections;
  final List<QuestionAnswerModel> filteredQuestions;

  const FaqState({
    this.status = UiStatus.initial,
    this.errorMessage,
    this.sections = const {},
    this.filteredQuestions = const [],
  });

  FaqState copyWith({
    UiStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    Map<String, List<QuestionAnswerModel>>? sections,
    List<QuestionAnswerModel>? filteredQuestions,
  }) {
    return FaqState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      sections: sections ?? this.sections,
      filteredQuestions: filteredQuestions ?? this.filteredQuestions,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, sections, filteredQuestions];
}