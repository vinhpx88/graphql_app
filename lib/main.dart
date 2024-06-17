import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_config.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'secure_storage_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  final SecureStorageService secureStorageService = SecureStorageService();
  final String? token = await secureStorageService.readToken();
  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String? initialToken;

  MyApp({this.initialToken});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig.initializeClient(),
      child: CacheProvider(
        child: MaterialApp(
          title: 'GraphQL Flutter App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: initialToken == null
              ? LoginScreen()
              : HomeScreen(
                  token: initialToken!,
                ),
        ),
      ),
    );
  }
}
