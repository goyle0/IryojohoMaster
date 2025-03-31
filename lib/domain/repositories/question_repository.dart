/// 問題データにアクセスするためのリポジトリインターフェイス
import 'package:iryojoho_master/domain/entities/question.dart';

abstract class QuestionRepository {
  /// 問題リストを取得する
  ///
  /// [category] 絞り込みたいカテゴリー（オプション）
  /// [subCategory] 絞り込みたいサブカテゴリー（オプション）
  ///
  /// 戻り値: 条件に合致する問題のリスト
  Future<List<Question>> getQuestions({String? category, String? subCategory});

  /// 特定のIDを持つ問題を取得する
  ///
  /// [id] 取得したい問題のID
  ///
  /// 戻り値: 指定されたIDの問題
  /// 例外: 問題が見つからない場合
  Future<Question> getQuestionById(String id);

  /// 問題データを同期する
  ///
  /// 例外: 同期に失敗した場合
  Future<void> syncQuestions();
}
