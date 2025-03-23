class LearningSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String category;
  final int questionCount;
  final int correctCount;

  LearningSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.category,
    required this.questionCount,
    required this.correctCount,
  });
}

