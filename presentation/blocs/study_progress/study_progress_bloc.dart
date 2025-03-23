import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/domain/entities/study_progress.dart';
import 'package:iryojoho_master/domain/repositories/study_progress_repository.dart';

// イベント
abstract class StudyProgressEvent {}

class LoadUserProgressEvent extends StudyProgressEvent {
  final String userId;

  LoadUserProgressEvent(this.userId);
}

class UpdateProgressEvent extends StudyProgressEvent {
  final String userId;
  final String questionId;
  final bool isCorrect;
  final double? confidenceScore;

  UpdateProgressEvent({
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    this.confidenceScore,
  });
}

class SyncProgressEvent extends StudyProgressEvent {}

// 状態
abstract class StudyProgressState {}

class StudyProgressInitialState extends StudyProgressState {}

class StudyProgressLoadingState extends StudyProgressState {}

class UserProgressLoadedState extends StudyProgressState {
  final List<StudyProgress> progressList;

  UserProgressLoadedState(this.progressList);
}

class ProgressUpdatedState extends StudyProgressState {
  final StudyProgress progress;

  ProgressUpdatedState(this.progress);
}

class StudyProgressErrorState extends StudyProgressState {
  final String message;

  StudyProgressErrorState(this.message);
}

// BLoC
class StudyProgressBloc extends Bloc<StudyProgressEvent, StudyProgressState> {
  final StudyProgressRepository studyProgressRepository;

  StudyProgressBloc({required this.studyProgressRepository})
      : super(StudyProgressInitialState()) {
    on<LoadUserProgressEvent>(_onLoadUserProgress);
    on<UpdateProgressEvent>(_onUpdateProgress);
    on<SyncProgressEvent>(_onSyncProgress);
  }

  Future<void> _onLoadUserProgress(
    LoadUserProgressEvent event,
    Emitter<StudyProgressState> emit,
  ) async {
    emit(StudyProgressLoadingState());
    try {
      final progressList = await studyProgressRepository.getUserProgress(event.userId);
      emit(UserProgressLoadedState(progressList));
    } catch (e) {
      emit(StudyProgressErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateProgress(
    UpdateProgressEvent event,
    Emitter<StudyProgressState> emit,
  ) async {
    emit(StudyProgressLoadingState());
    try {
      final progress = await studyProgressRepository.updateProgress(
        event.userId,
        event.questionId,
        event.isCorrect,
        event.confidenceScore,
      );
      emit(ProgressUpdatedState(progress));
    } catch (e) {
      emit(StudyProgressErrorState(e.toString()));
    }
  }

  Future<void> _onSyncProgress(
    SyncProgressEvent event,
    Emitter<StudyProgressState> emit,
  ) async {
    try {
      await studyProgressRepository.syncProgress();
      // 現在の状態を維持し、バックグラウンドで同期するだけ
    } catch (e) {
      // サイレントに失敗し、状態を更新しない
    }
  }
}

