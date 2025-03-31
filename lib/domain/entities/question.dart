/// 問題を表すエンティティクラス
import 'package:iryojoho_master/domain/entities/answer.dart';

class Question {
  /// 問題の一意識別子
  final String id;

  /// 問題のカテゴリー（例：医学・医療系、情報処理技術系など）
  final String category;

  /// 問題のサブカテゴリー
  final String subCategory;

  /// 問題のタイトル
  final String title;

  /// 問題の内容
  final String content;

  /// 問題の選択肢リスト
  final List<String> options;

  /// 正解の選択肢のインデックス
  final int correctOptionIndex;

  /// 問題の解説（存在しない場合はnull）
  final String? explanation;

  /// 問題オブジェクトのコンストラクタ
  ///
  /// [id] 問題ID
  /// [category] 問題カテゴリー
  /// [subCategory] 問題サブカテゴリー
  /// [title] 問題タイトル
  /// [content] 問題内容
  /// [options] 選択肢リスト
  /// [correctOptionIndex] 正解の選択肢のインデックス
  /// [explanation] 問題の解説（オプション）
  const Question({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.title,
    required this.content,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });
}
