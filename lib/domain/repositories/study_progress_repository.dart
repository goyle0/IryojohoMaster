import 'package:iryojoho_master/domain/entities/study_progress.dart';

abstract class StudyProgressRepository {
  Future<List<StudyProgress>> getUserProgress(String userId);
  Future<StudyProgress> updateProgress(
    String userId,
    String questionId,
    bool isCorrect,
    double? confidenceScore,
  );
  Future<void> syncProgress();
}

