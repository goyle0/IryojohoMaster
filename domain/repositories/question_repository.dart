import 'package:iryojoho_master/domain/entities/question.dart';

abstract class QuestionRepository {
  Future<List<Question>> getQuestions({String? category, String? subCategory});
  Future<Question> getQuestionById(String id);
  Future<void> syncQuestions();
}

