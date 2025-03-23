class Answer {
  final String id;
  final String questionId;
  final String text;
  final bool isCorrect;
  final int orderIndex;

  Answer({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
    required this.orderIndex,
  });
}

