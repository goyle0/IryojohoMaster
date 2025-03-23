import 'package:iryojoho_master/domain/entities/answer.dart';

class Question {
  final String id;
  final String category;
  final String subCategory;
  final String text;
  final List<Answer> answers;
  final String explanation;
  final int difficulty;
  final String? imageUrl;

  Question({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.text,
    required this.answers,
    required this.explanation,
    required this.difficulty,
    this.imageUrl,
  });
}

