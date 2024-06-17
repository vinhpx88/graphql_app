// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_service.dart';
import 'submit_question_bottom_sheet.dart';
import 'login_screen.dart';
import 'question.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GraphQLService _graphQLService;
  List<Question> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _graphQLService = GraphQLService(widget.token);
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
    });

    final QueryResult result = await _graphQLService.fetchQuestions();

    if (result.hasException) {
      print('Error fetching questions: ${result.exception.toString()}');
    } else {
      final List<Question> questions = result.data!['users'][0]['questions']
          .map((q) => Question.fromJson(q))
          .toList()
          .cast<Question>();

      setState(() {
        _questions = questions;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchQuestions,
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return ListTile(
                    title: Text(question.question),
                    subtitle: Text(question.answer ?? 'No answer yet'),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) =>
                SubmitQuestionBottomSheet(token: widget.token),
          ).then((_) {
            // Refresh questions after submitting a new one
            _fetchQuestions();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
