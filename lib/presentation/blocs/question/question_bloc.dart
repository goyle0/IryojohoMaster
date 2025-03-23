import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/domain/entities/question.dart';
import 'package:iryojoho_master/domain/repositories/question_repository.dart';

// イベント
abstract class QuestionEvent {}

class LoadQuestionsEvent extends QuestionEvent {
  final String? category;
  final String? subCategory;

  LoadQuestionsEvent({this.category, this.subCategory});
}

class LoadQuestionDetailEvent extends QuestionEvent {
  final String questionId;

  LoadQuestionDetailEvent(this.questionId);
}

class SyncQuestionsEvent extends QuestionEvent {}

// 状態
abstract class QuestionState {}

class QuestionInitialState extends QuestionState {}

class QuestionsLoadingState extends QuestionState {}

class QuestionsLoadedState extends QuestionState {
  final List<Question> questions;

  QuestionsLoadedState(this.questions);
}

class QuestionDetailLoadedState extends QuestionState {
  final Question question;

  QuestionDetailLoadedState(this.question);
}

class QuestionErrorState extends QuestionState {
  final String message;

  QuestionErrorState(this.message);
}

// BLoC
class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final QuestionRepository questionRepository;

  QuestionBloc({required this.questionRepository}) : super(QuestionInitialState()) {
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<LoadQuestionDetailEvent>(_onLoadQuestionDetail);
    on<SyncQuestionsEvent>(_onSyncQuestions);
  }

  Future<void> _onLoadQuestions(
    LoadQuestionsEvent event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionsLoadingState());
    try {
      final questions = await questionRepository.getQuestions(
        category: event.category,
        subCategory: event.subCategory,
      );
      emit(QuestionsLoadedState(questions));
    } catch (e) {
      emit(QuestionErrorState(e.toString()));
    }
  }

  Future<void> _onLoadQuestionDetail(
    LoadQuestionDetailEvent event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionsLoadingState());
    try {
      final question = await questionRepository.getQuestionById(event.questionId);
      emit(QuestionDetailLoadedState(question));
    } catch (e) {
      emit(QuestionErrorState(e.toString()));
    }
  }

  Future<void> _onSyncQuestions(
    SyncQuestionsEvent event,
    Emitter<QuestionState> emit,
  ) async {
    try {
      await questionRepository.syncQuestions();
      // 現在の状態を維持し、バックグラウンドで同期するだけ
    } catch (e) {
      // サイレントに失敗し、状態を更新しない
    }
  }
}

