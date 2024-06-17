import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GraphQLService {
  late GraphQLClient _client;

  GraphQLService(String token) {
    final HttpLink httpLink = HttpLink(dotenv.env['GRAPHQL_SERVER_URL']!);

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );

    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  GraphQLClient get client => _client;

  Future<QueryResult> postQuestion(String question) {
    const String postQuestionMutation = """
      mutation PostQuestion(\$userId: ID!, \$question: String!) {
        postQuestion(userId: \$userId, question: \$question) {
          id
          question
          answer
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: gql(postQuestionMutation),
      variables: {
        'userId': "",
        'question': question,
      },
    );

    return _client.mutate(options);
  }

  Future<QueryResult> fetchQuestions() async {
    const String getQuestionsQuery = """
      query {
        users {
          questions {
            id
            question
            answer
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(
        document: gql(getQuestionsQuery),
        fetchPolicy: FetchPolicy.cacheAndNetwork);

    return _client.query(options);
  }
}
