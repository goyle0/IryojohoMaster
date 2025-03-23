class StudyProgress {
  final String id;
  final String userId;
  final String questionId;
  final bool isCorrect;
  final int attemptCount;
  final DateTime lastAttemptAt;
  final double? confidenceScore;

  StudyProgress({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    required this.attemptCount,
    required this.lastAttemptAt,
    this.confidenceScore,
  });
}

