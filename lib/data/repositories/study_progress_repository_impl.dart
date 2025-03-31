/// 学習進捗リポジトリの実装クラス
/// Supabaseを使用して学習進捗データの取得や更新を行う
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iryojoho_master/domain/entities/study_progress.dart';
import 'package:iryojoho_master/domain/repositories/study_progress_repository.dart';

class StudyProgressRepositoryImpl implements StudyProgressRepository {
  /// Supabaseクライアントのインスタンス
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<StudyProgress>> getUserProgress(String userId) async {
    try {
      // ユーザーIDに基づいて進捗データを取得
      final data = await _supabase
          .from('study_progress')
          .select('*')
          .eq('user_id', userId)
          .order('answered_at', ascending: false);

      // StudyProgressオブジェクトに変換
      return data
          .map<StudyProgress>(
            (item) => StudyProgress(
              id: item['id'],
              userId: item['user_id'],
              questionId: item['question_id'],
              isCorrect: item['is_correct'],
              confidenceScore: item['confidence_score'],
              answeredAt: DateTime.parse(item['answered_at']),
            ),
          )
          .toList();
    } catch (e) {
      // エラーログ
      print('Error fetching user progress: $e');
      throw Exception('Failed to load study progress: $e');
    }
  }

  @override
  Future<StudyProgress> updateProgress(
    String userId,
    String questionId,
    bool isCorrect,
    double? confidenceScore,
  ) async {
    try {
      // 進捗データを作成・更新するためのデータ
      final progressData = {
        'user_id': userId,
        'question_id': questionId,
        'is_correct': isCorrect,
        'confidence_score': confidenceScore,
        'answered_at': DateTime.now().toIso8601String(),
      };

      // upsert操作を実行（存在すれば更新、なければ挿入）
      final data =
          await _supabase
              .from('study_progress')
              .upsert(progressData)
              .select()
              .single();

      // 作成・更新された進捗データをStudyProgressオブジェクトに変換して返す
      return StudyProgress(
        id: data['id'],
        userId: data['user_id'],
        questionId: data['question_id'],
        isCorrect: data['is_correct'],
        confidenceScore: data['confidence_score'],
        answeredAt: DateTime.parse(data['answered_at']),
      );
    } catch (e) {
      // エラーログ
      print('Error updating progress: $e');
      throw Exception('Failed to update study progress: $e');
    }
  }

  @override
  Future<void> syncProgress() async {
    // リアルタイムで同期されるため、ここでは特別な処理は不要
  }
}
