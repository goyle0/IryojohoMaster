/// 学習進捗データにアクセスするためのリポジトリインターフェイス
import 'package:iryojoho_master/domain/entities/study_progress.dart';

abstract class StudyProgressRepository {
  /// 特定ユーザーの学習進捗を取得する
  ///
  /// [userId] 進捗を取得したいユーザーのID
  ///
  /// 戻り値: ユーザーの学習進捗リスト
  Future<List<StudyProgress>> getUserProgress(String userId);

  /// ユーザーの問題解答結果を記録・更新する
  ///
  /// [userId] 記録するユーザーのID
  /// [questionId] 回答した問題のID
  /// [isCorrect] 解答が正解だったかどうか
  /// [confidenceScore] 解答時の自信度スコア（オプション）
  ///
  /// 戻り値: 作成・更新された学習進捗情報
  Future<StudyProgress> updateProgress(
    String userId,
    String questionId,
    bool isCorrect,
    double? confidenceScore,
  );

  /// 学習進捗データを同期する
  ///
  /// 例外: 同期に失敗した場合
  Future<void> syncProgress();
}
