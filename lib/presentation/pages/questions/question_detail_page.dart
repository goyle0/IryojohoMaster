import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/question/question_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/study_progress/study_progress_bloc.dart';

class QuestionDetailPage extends StatefulWidget {
  final String questionId;

  const QuestionDetailPage({Key? key, required this.questionId})
    : super(key: key);

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  int? _selectedAnswer;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    context.read<QuestionBloc>().add(
      LoadQuestionDetailEvent(widget.questionId),
    );
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    final state = context.read<QuestionBloc>().state;
    if (state is QuestionDetailLoadedState) {
      final question = state.question;
      final isCorrect = _selectedAnswer == question.correctOptionIndex;

      context.read<StudyProgressBloc>().add(
        UpdateProgressEvent(
          userId: '1', // TODO: 実際のユーザーIDを使用
          questionId: widget.questionId,
          isCorrect: isCorrect,
        ),
      );

      setState(() {
        _showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('問題')),
      body: BlocBuilder<QuestionBloc, QuestionState>(
        builder: (context, state) {
          if (state is QuestionsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuestionDetailLoadedState) {
            final question = state.question;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    question.options.length,
                    (index) => RadioListTile<int>(
                      title: Text(question.options[index]),
                      value: index,
                      groupValue: _selectedAnswer,
                      onChanged:
                          _showResult
                              ? null
                              : (value) {
                                setState(() {
                                  _selectedAnswer = value;
                                });
                              },
                      tileColor:
                          _showResult
                              ? index == question.correctOptionIndex
                                  ? Colors.green.withOpacity(0.1)
                                  : _selectedAnswer == index
                                  ? Colors.red.withOpacity(0.1)
                                  : null
                              : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_showResult && question.explanation != null) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('解説:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(question.explanation!),
                  ],
                  const SizedBox(height: 24),
                  if (!_showResult)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _selectedAnswer != null ? _submitAnswer : null,
                        child: const Text('回答する'),
                      ),
                    ),
                  if (_showResult)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('戻る'),
                      ),
                    ),
                ],
              ),
            );
          }

          if (state is QuestionErrorState) {
            return Center(child: Text('エラー: ${state.message}'));
          }

          return const Center(child: Text('問題が見つかりません'));
        },
      ),
    );
  }
}
