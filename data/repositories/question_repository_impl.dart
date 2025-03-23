import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iryojoho_master/domain/entities/question.dart';
import 'package:iryojoho_master/domain/repositories/question_repository.dart';
import 'package:iryojoho_master/data/models/question_model.dart';
import 'package:iryojoho_master/data/models/answer_model.dart';
import 'package:iryojoho_master/core/utils/connectivity_service.dart';
import 'package:iryojoho_master/data/datasources/local/database_helper.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ConnectivityService _connectivity = ConnectivityService();

  @override
  Future<List<Question>> getQuestions({String? category, String? subCategory}) async {
    // まずローカルデータベースから問題を取得
    final localQuestions = await _dbHelper.getQuestions(
      category: category,
      subCategory: subCategory,
    );

    // オンラインの場合、サーバーと同期して更新されたデータを返す
    if (await _connectivity.isConnected()) {
      try {
        await syncQuestions();
        return await _dbHelper.getQuestions(
          category: category,
          subCategory: subCategory,
        );
      } catch (e) {
        // エラー時はローカルデータを使用
        return localQuestions;
      }
    }

    return localQuestions;
  }

  @override
  Future<Question> getQuestionById(String id) async {
    // まずローカルデータベースから問題を取得
    final localQuestion = await _dbHelper.getQuestionById(id);
    if (localQuestion != null) {
      return localQuestion;
    }

    // オンラインの場合、サーバーから取得
    if (await _connectivity.isConnected()) {
      final questionData = await _supabase
          .from('questions')
          .select('*, answers(*)')
          .eq('id', id)
          .single();

      final answers = (questionData['answers'] as List)
          .map((answer) => AnswerModel.fromJson(answer))
          .toList();

      final question = QuestionModel.fromJson({
        ...questionData,
        'answers': answers,
      });

      // ローカルデータベースに保存
      await _dbHelper.saveQuestion(question);
      return question;
    }

    throw Exception('質問が見つかりません');
  }

  @override
  Future<void> syncQuestions() async {
    if (!await _connectivity.isConnected()) {
      return;
    }

    // 最後の同期タイムスタンプを取得
    final lastSync = await _dbHelper.getLastSyncTimestamp();

    // 最後の同期以降に更新された問題を取得
    var query = _supabase.from('questions').select('*, answers(*)');
    
    if (lastSync != null) {
      query = query.gt('updated_at', lastSync);
    }

    final questionsData = await query.execute();
    
    // 取得した問題をローカルデータベースに保存
    for (final questionData in questionsData.data) {
      final answers = (questionData['answers'] as List)
          .map((answer) => AnswerModel.fromJson(answer))
          .toList();

      final question = QuestionModel.fromJson({
        ...questionData,
        'answers': answers,
      });

      await _dbHelper.saveQuestion(question);
    }

    // 最後の同期タイムスタンプを更新
    await _dbHelper.updateLastSyncTimestamp(DateTime.now());
  }
}

