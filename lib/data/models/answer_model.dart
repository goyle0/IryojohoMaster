import 'package:iryojoho_master/domain/entities/answer.dart';

class AnswerModel extends Answer {
  AnswerModel({
    required String id,
    required String questionId,
    required String text,
    required bool isCorrect,
    required int orderIndex,
  }) : super(
          id: id,
          questionId: questionId,
          text: text,
          isCorrect: isCorrect,
          orderIndex: orderIndex,
        );

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'],
      questionId: json['question_id'],
      text: json['text'],
      isCorrect: json['is_correct'],
      orderIndex: json['order_index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'text': text,
      'is_correct': isCorrect,
      'order_index': orderIndex,
    };
  }
}

