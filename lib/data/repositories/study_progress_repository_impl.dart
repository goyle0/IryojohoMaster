import 'package:iryojoho_master/domain/entities/study_progress.dart';
import 'package:iryojoho_master/domain/repositories/study_progress_repository.dart';

class StudyProgressRepositoryImpl implements StudyProgressRepository {
  // デモ用のモックデータ
  final Map<String, List<StudyProgress>> _mockProgress = {};

  @override
  Future<List<StudyProgress>> getUserProgress(String userId) async {
    // ユーザーの進捗がない場合は、デモデータを生成
    if (!_mockProgress.containsKey(userId)) {
      _mockProgress[userId] = List.generate(
        20,
        (i) => StudyProgress(
          id: 'p$i',
          userId: userId,
          questionId: 'q${i % 3 + 1}', // q1, q2, q3 のいずれか
          isCorrect: i % 2 == 0,
          confidenceScore: (i % 5 + 1) / 5, // 0.2から1.0の間
          answeredAt: DateTime.now().subtract(Duration(days: i)),
        ),
      );
    }

    return _mockProgress[userId] ?? [];
  }

  @override
  Future<StudyProgress> updateProgress(
    String userId,
    String questionId,
    bool isCorrect,
    double? confidenceScore,
  ) async {
    final progress = StudyProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      questionId: questionId,
      isCorrect: isCorrect,
      confidenceScore: confidenceScore,
      answeredAt: DateTime.now(),
    );

    _mockProgress.update(
      userId,
      (list) => [...list, progress],
      ifAbsent: () => [progress],
    );

    return progress;
  }

  @override
  Future<void> syncProgress() async {
    // 実際のアプリケーションでは、ここでリモートサーバーとの同期を行います
    await Future.delayed(const Duration(seconds: 1));
  }
}
