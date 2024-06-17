// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'graphql_service.dart';

class SubmitQuestionBottomSheet extends StatefulWidget {
  final String token;

  const SubmitQuestionBottomSheet({super.key, required this.token});

  @override
  _SubmitQuestionBottomSheetState createState() =>
      _SubmitQuestionBottomSheetState();
}

class _SubmitQuestionBottomSheetState extends State<SubmitQuestionBottomSheet> {
  final TextEditingController _questionController = TextEditingController();
  late GraphQLService _graphQLService;

  @override
  void initState() {
    super.initState();
    _graphQLService = GraphQLService(widget.token);
  }

  void _submitQuestion(BuildContext context) async {

    try {
      final result =
          await _graphQLService.postQuestion(_questionController.text);
      if (result.hasException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error submitting question: ${result.exception.toString()}')),
        );
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting question: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                // autofocus: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitQuestion(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
