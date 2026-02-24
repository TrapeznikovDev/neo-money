import 'dart:convert';

class QuestionAnswerModel {
  final String question;
  final String answer;

  QuestionAnswerModel({this.question = '', this.answer = ''});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'question': question,
      'answer': answer,
    };
  }

  factory QuestionAnswerModel.fromMap(Map<String, dynamic> map) {
    return QuestionAnswerModel(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory QuestionAnswerModel.fromJson(String source) =>
      QuestionAnswerModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
