import 'package:iryojoho_master/domain/entities/study_progress.dart';

class StudyProgressModel extends StudyProgress {
  StudyProgressModel({
    required String id,
    required String userId,
    required String questionId,
    required bool isCorrect,
    required int attemptCount,
    required DateTime lastAttemptAt,
    double? confidenceScore,
  }) : super(
          id: id,
          userId: userId,
          questionId: questionId,
          isCorrect: isCorrect,
          attemptCount: attemptCount,
          lastAttemptAt: lastAttemptAt,
          confidenceScore: confidenceScore,
        );

  factory StudyProgressModel.fromJson(Map<String, dynamic> json) {
    return StudyProgressModel(
      id: json['id'],
      userId: json['user_id'],
      questionId: json['question_id'],
      isCorrect: json['is_correct'],
      attemptCount: json['attempt_count'],
      lastAttemptAt: DateTime.parse(json['last_attempt_at']),
      confidenceScore: json['confidence_score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'question_id': questionId,
      'is_correct': isCorrect,
      'attempt_count': attemptCount,
      'last_attempt_at': lastAttemptAt.toIso8601String(),
      'confidence_score': confidenceScore,
    };
  }
}

