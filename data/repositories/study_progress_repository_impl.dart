import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iryojoho_master/domain/entities/study_progress.dart';
import 'package:iryojoho_master/domain/repositories/study_progress_repository.dart';
import 'package:iryojoho_master/data/models/study_progress_model.dart';
import 'package:iryojoho_master/core/utils/connectivity_service.dart';
import 'package:iryojoho_master/data/datasources/local/database_helper.dart';

class StudyProgressRepositoryImpl implements StudyProgressRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  Future<List<StudyProgress>> getUserProgress(String userId) async {
    // ローカルデータベースから進捗を取得
    final localProgress = await _dbHelper.getUserProgress(userId);

    // オンラインの場合、サーバーと同期
    if (await _connectivity.isConnected()) {
      try {
        await syncProgress();
        return await _dbHelper.getUserProgress(userId);
      } catch (e) {
        return localProgress;
      }
    }

    return localProgress;
  }

  @override
  Future<StudyProgress> updateProgress(
    String userId,
    String questionId,
    bool isCorrect,
    double? confidenceScore,
  ) async {
    // 既存の進捗があれば取得
    final existingProgress = await _dbHelper.getProgressByUserAndQuestion(
      userId,
      questionId,
    );

    final now = DateTime.now();
    StudyProgressModel progressModel;

    if (existingProgress != null) {
      // 既存の進捗を更新
      progressModel = StudyProgressModel(
        id: existingProgress.id,
        userId: userId,
        questionId: questionId,
        isCorrect: isCorrect,
        attemptCount: existingProgress.attemptCount + 1,
        lastAttemptAt: now,
        confidenceScore: confidenceScore,
      );
    } else {
      // 新しい進捗を作成
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      progressModel = StudyProgressModel(
        id: id,
        userId: userId,
        questionId: questionId,
        isCorrect: isCorrect,
        attemptCount: 1,
        lastAttemptAt: now,
        confidenceScore: confidenceScore,
      );
    }

    // ローカルデータベースに保存
    await _dbHelper.saveProgress(progressModel);

    // オンラインの場合、サーバーと同期
    if (await _connectivity.isConnected()) {
      try {
        final data = progressModel.toJson();
        
        if (existingProgress != null) {
          // サーバー上で更新
          await _supabase
              .from('study_progress')
              .update(data)
              .eq('id', progressModel.id);
        } else {
          // サーバーに挿入
          await _supabase.from('study_progress').insert(data);
        }
      } catch (e) {
        // 後で同期するためにマーク
        await _dbHelper.markForSync(progressModel.id, 'study_progress');
      }
    } else {
      // 後で同期するためにマーク
      await _dbHelper.markForSync(progressModel.id, 'study_progress');
    }

    return progressModel;
  }

  @override
  Future<void> syncProgress() async {
    if (!await _connectivity.isConnected()) {
      return;
    }

    // 同期のためにマークされたアイテムを取得
    final pendingSyncs = await _dbHelper.getPendingSyncs('study_progress');

    // 各アイテムを同期
    for (final sync in pendingSyncs) {
      final progress = await _dbHelper.getProgressById(sync.itemId);
      if (progress != null) {
        try {
          // アイテムがサーバー上に存在するか確認
          final exists = await _supabase
              .from('study_progress')
              .select('id')
              .eq('id', progress.id)
              .maybeSingle();

          if (exists != null) {
            // 更新
            await _supabase
                .from('study_progress')
                .update(StudyProgressModel(
                  id: progress.id,
                  userId: progress.userId,
                  questionId: progress.questionId,
                  isCorrect: progress.isCorrect,
                  attemptCount: progress.attemptCount,
                  lastAttemptAt: progress.lastAttemptAt,
                  confidenceScore: progress.confidenceScore,
                ).toJson())
                .eq('id', progress.id);
          } else {
            // 挿入
            await _supabase.from('study_progress').insert(
                  StudyProgressModel(
                    id: progress.id,
                    userId: progress.userId,
                    questionId: progress.questionId,
                    isCorrect: progress.isCorrect,
                    attemptCount: progress.attemptCount,
                    lastAttemptAt: progress.lastAttemptAt,
                    confidenceScore: progress.confidenceScore,
                  ).toJson(),
                );
          }

          // 同期フラグをクリア
          await _dbHelper.clearSyncFlag(progress.id, 'study_progress');
        } catch (e) {
          // 次の試行のために同期フラグを保持
        }
      }
    }

    // サーバーの更新を取得
    final lastSync = await _dbHelper.getLastSyncTimestamp();
    var query = _supabase.from('study_progress').select();
    
    if (lastSync != null) {
      query = query.gt('updated_at', lastSync);
    }

    final serverData = await query.execute();
    
    // サーバーデータでローカルデータベースを更新
    for (final item in serverData.data) {
      final progress = StudyProgressModel.fromJson(item);
      await _dbHelper.saveProgress(progress);
    }

    // 最後の同期タイムスタンプを更新
    await _dbHelper.updateLastSyncTimestamp(DateTime.now());
  }
}

