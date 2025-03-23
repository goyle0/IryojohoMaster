import 'package:iryojoho_master/domain/entities/answer.dart';

class Question {
  final String id;
  final String category;
  final String subCategory;
  final String title;
  final String content;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  const Question({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.title,
    required this.content,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });
}
