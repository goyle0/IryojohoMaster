import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/app/routes.dart';
import 'package:iryojoho_master/presentation/blocs/question/question_bloc.dart';

class QuestionListPage extends StatefulWidget {
  final String? category;

  const QuestionListPage({Key? key, this.category}) : super(key: key);

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  @override
  void initState() {
    super.initState();
    context.read<QuestionBloc>().add(
      LoadQuestionsEvent(category: widget.category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category ?? '全ての問題')),
      body: BlocBuilder<QuestionBloc, QuestionState>(
        builder: (context, state) {
          if (state is QuestionsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuestionsLoadedState) {
            return ListView.builder(
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final question = state.questions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(question.title),
                    subtitle: Text(question.content),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.questionDetail,
                        arguments: {'questionId': question.id},
                      );
                    },
                  ),
                );
              },
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
