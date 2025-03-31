/// 学習進捗を表すエンティティクラス
/// ユーザーの問題解答履歴や正誤情報を管理する
class StudyProgress {
  /// 進捗記録の一意識別子
  final String id;

  /// 進捗を記録しているユーザーのID
  final String userId;

  /// 回答した問題のID
  final String questionId;

  /// 解答が正解だったかどうか
  final bool isCorrect;

  /// 解答時の自信度スコア（0.0〜1.0、設定されていない場合はnull）
  final double? confidenceScore;

  /// 解答した日時
  final DateTime answeredAt;

  /// 学習進捗オブジェクトのコンストラクタ
  ///
  /// [id] 進捗ID
  /// [userId] ユーザーID
  /// [questionId] 問題ID
  /// [isCorrect] 正解したかどうか
  /// [confidenceScore] 自信度スコア（オプション）
  /// [answeredAt] 解答日時
  const StudyProgress({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    this.confidenceScore,
    required this.answeredAt,
  });
}
