import 'package:neomoney/features/faq/models/question_answer_model.dart';

abstract class FaqRepository {
  Future<Map<String, List<QuestionAnswerModel>>> getQuestionsAnswers();
}