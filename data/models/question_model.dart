import 'package:iryojoho_master/domain/entities/question.dart';
import 'package:iryojoho_master/data/models/answer_model.dart';

class QuestionModel extends Question {
  QuestionModel({
    required String id,
    required String category,
    required String subCategory,
    required String text,
    required List<AnswerModel> answers,
    required String explanation,
    required int difficulty,
    String? imageUrl,
  }) : super(
          id: id,
          category: category,
          subCategory: subCategory,
          text: text,
          answers: answers,
          explanation: explanation,
          difficulty: difficulty,
          imageUrl: imageUrl,
        );

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      category: json['category'],
      subCategory: json['sub_category'],
      text: json['text'],
      answers: (json['answers'] as List)
          .map((answer) => AnswerModel.fromJson(answer))
          .toList(),
      explanation: json['explanation'],
      difficulty: json['difficulty'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'sub_category': subCategory,
      'text': text,
      'explanation': explanation,
      'difficulty': difficulty,
      'image_url': imageUrl,
    };
  }
}

