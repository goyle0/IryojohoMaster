/// 問題データリポジトリの実装クラス
/// Supabaseを使用して問題データの取得や管理を行う
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iryojoho_master/domain/entities/question.dart';
import 'package:iryojoho_master/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  /// Supabaseクライアントのインスタンス
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Question>> getQuestions({
    String? category,
    String? subCategory,
  }) async {
    try {
      // Supabaseクエリを構築
      var query = _supabase.from('questions').select('*');

      // カテゴリーによるフィルタリング
      if (category != null) {
        query = query.eq('category', category);
      }

      // サブカテゴリーによるフィルタリング
      if (subCategory != null) {
        query = query.eq('sub_category', subCategory);
      }

      // データを取得
      final data = await query;

      // Questionオブジェクトに変換
      return data
          .map<Question>(
            (item) => Question(
              id: item['id'],
              category: item['category'],
              subCategory: item['sub_category'],
              title: item['title'],
              content: item['content'],
              options: List<String>.from(item['options']),
              correctOptionIndex: item['correct_option_index'],
              explanation: item['explanation'],
            ),
          )
          .toList();
    } catch (e) {
      // エラーログ
      print('Error fetching questions: $e');
      throw Exception('Failed to load questions: $e');
    }
  }

  @override
  Future<Question> getQuestionById(String id) async {
    try {
      // IDで質問を検索
      final data =
          await _supabase.from('questions').select('*').eq('id', id).single();

      // Questionオブジェクトに変換
      return Question(
        id: data['id'],
        category: data['category'],
        subCategory: data['sub_category'],
        title: data['title'],
        content: data['content'],
        options: List<String>.from(data['options']),
        correctOptionIndex: data['correct_option_index'],
        explanation: data['explanation'],
      );
    } catch (e) {
      // エラーログ
      print('Error fetching question by ID: $e');
      throw Exception('Failed to load question: $e');
    }
  }

  @override
  Future<void> syncQuestions() async {
    // すでにリアルタイムで同期されるためここでは追加の操作は不要
  }
}
