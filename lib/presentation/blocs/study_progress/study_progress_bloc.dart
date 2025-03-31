/// 学習進捗に関する状態管理を行うBLoCクラス
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/domain/entities/study_progress.dart';
import 'package:iryojoho_master/domain/repositories/study_progress_repository.dart';

/// 学習進捗に関するイベント定義
abstract class StudyProgressEvent {}

/// ユーザーの学習進捗を読み込むイベント
class LoadUserProgressEvent extends StudyProgressEvent {
  /// 進捗を読み込むユーザーのID
  final String userId;

  LoadUserProgressEvent(this.userId);
}

/// 学習進捗を更新するイベント
class UpdateProgressEvent extends StudyProgressEvent {
  /// 進捗を更新するユーザーのID
  final String userId;

  /// 回答した問題のID
  final String questionId;

  /// 回答が正解だったかどうか
  final bool isCorrect;

  /// 回答時の自信度スコア（オプション）
  final double? confidenceScore;

  UpdateProgressEvent({
    required this.userId,
    required this.questionId,
    required this.isCorrect,
    this.confidenceScore,
  });
}

/// 学習進捗データを同期するイベント
class SyncProgressEvent extends StudyProgressEvent {}

/// 学習進捗に関する状態定義
abstract class StudyProgressState {}

/// 初期状態
class StudyProgressInitialState extends StudyProgressState {}

/// データ読み込み中の状態
class StudyProgressLoadingState extends StudyProgressState {}

/// ユーザー進捗データが読み込まれた状態
class UserProgressLoadedState extends StudyProgressState {
  /// 読み込まれた進捗リスト
  final List<StudyProgress> progressList;

  UserProgressLoadedState(this.progressList);
}

/// 進捗が更新された状態
class ProgressUpdatedState extends StudyProgressState {
  /// 更新された進捗情報
  final StudyProgress progress;

  ProgressUpdatedState(this.progress);
}

/// エラー状態
class StudyProgressErrorState extends StudyProgressState {
  /// エラーメッセージ
  final String message;

  StudyProgressErrorState(this.message);
}

/// ユーザー進捗データを表すモデルクラス
class UserProgress {
  /// 回答した問題のID
  final String questionId;

  /// 回答が正解だったかどうか
  final bool isCorrect;

  /// 回答した日時
  final DateTime answeredAt;

  UserProgress({
    required this.questionId,
    required this.isCorrect,
    required this.answeredAt,
  });
}

/// 学習進捗BLoCの実装
class StudyProgressBloc extends Bloc<StudyProgressEvent, StudyProgressState> {
  /// 学習進捗リポジトリ
  final StudyProgressRepository studyProgressRepository;

  /// StudyProgressBlocのコンストラクタ
  ///
  /// [studyProgressRepository] 学習進捗データにアクセスするリポジトリ
  StudyProgressBloc({required this.studyProgressRepository})
    : super(StudyProgressInitialState()) {
    on<LoadUserProgressEvent>(_onLoadUserProgress);
    on<UpdateProgressEvent>(_onUpdateProgress);
    on<SyncProgressEvent>(_onSyncProgress);
  }

  /// ユーザー進捗読み込みイベントのハンドラ
  Future<void> _onLoadUserProgress(
    LoadUserProgressEvent event,
    Emitter<StudyProgressState> emit,
  ) async {
    emit(StudyProgressLoadingState());
    try {
      final progressList = await studyProgressRepository.getUserProgress(
        event.userId,
      );
      emit(UserProgressLoadedState(progressList));
    } catch (e) {
      emit(StudyProgressErrorState(e.toString()));
    }
  }

  /// 進捗更新イベントのハンドラ
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

  /// 進捗同期イベントのハンドラ
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
