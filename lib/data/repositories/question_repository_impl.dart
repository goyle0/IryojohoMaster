import 'package:iryojoho_master/domain/entities/question.dart';
import 'package:iryojoho_master/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  // デモ用のモックデータ
  final List<Question> _mockQuestions = [
    Question(
      id: 'q1',
      category: '医学・医療系',
      subCategory: '医療情報基礎知識',
      title: '医療情報システムの目的',
      content: '医療情報システムの主な目的として、最も適切なものはどれか？',
      options: ['医療費の削減のため', '患者サービスの向上のため', 'スタッフの作業効率化のため', '病院の収益向上のため'],
      correctOptionIndex: 1,
      explanation: '医療情報システムの主な目的は、患者サービスの向上です。効率化や収益向上は副次的な効果として期待されます。',
    ),
    Question(
      id: 'q2',
      category: '情報処理技術系',
      subCategory: 'データベース',
      title: 'データベース設計',
      content: '医療情報システムにおけるデータベースの正規化の目的として、最も適切なものはどれか？',
      options: ['データの冗長性の排除', 'データの高速化', 'データの暗号化', 'データの圧縮'],
      correctOptionIndex: 0,
      explanation: 'データベースの正規化は、主にデータの冗長性を排除し、データの整合性を保つために行います。',
    ),
    Question(
      id: 'q3',
      category: '医療情報システム系',
      subCategory: '医療情報の標準化',
      title: 'HL7について',
      content: 'HL7の主な目的として、最も適切なものはどれか？',
      options: ['医療機器の規格統一', '医療情報の交換規格の標準化', '医療保険の請求形式の統一', '医療用語の統一'],
      correctOptionIndex: 1,
      explanation: 'HL7は、医療情報システム間での情報交換を標準化するための規格です。',
    ),
  ];

  @override
  Future<List<Question>> getQuestions({
    String? category,
    String? subCategory,
  }) async {
    // カテゴリーによるフィルタリング
    if (category != null) {
      return _mockQuestions.where((q) => q.category == category).toList();
    }
    return _mockQuestions;
  }

  @override
  Future<Question> getQuestionById(String id) async {
    final question = _mockQuestions.firstWhere(
      (q) => q.id == id,
      orElse: () => throw Exception('Question not found'),
    );
    return question;
  }

  @override
  Future<void> syncQuestions() async {
    // 実際のアプリケーションでは、ここでリモートサーバーとの同期を行います
    await Future.delayed(const Duration(seconds: 1));
  }
}
