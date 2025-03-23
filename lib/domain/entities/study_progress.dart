class StudyProgress {
  final String id;
  final String userId;
  final String questionId;
  final bool isCorrect;
  final double? confidenceScore;
  final DateTime answeredAt;

  const StudyProgress({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    this.confidenceScore,
    required this.answeredAt,
  });
}
