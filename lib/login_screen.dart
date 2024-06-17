// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'home_screen.dart';
import 'secure_storage_service.dart';
import 'graphql_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late GraphQLService _graphQLService;
  final SecureStorageService _secureStorageService = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _graphQLService = GraphQLService('');
  }

  void _login(BuildContext context) async {
    const String loginMutation = """
      mutation Login(\$email: String!, \$password: String!) {
        login(email: \$email, password: \$password) {
          token
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: gql(loginMutation),
      variables: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    final QueryResult result = await _graphQLService.client.mutate(options);

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in: ${result.exception.toString()}')),
      );
    } else {
      final String token = result.data!['login']['token'];
      await _secureStorageService.writeToken(token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login(context);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
