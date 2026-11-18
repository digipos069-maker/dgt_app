import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../features/auth/application/auth_controller.dart';
import 'authenticated_http_client.dart';

/// The one HTTP client every API service should use.
///
/// A 401 on a request made with the signed-in user's token ends the session,
/// which sends the user back to the login page through the router redirect.
final apiHttpClientProvider = Provider<http.Client>((ref) {
  final client = AuthenticatedHttpClient(
    inner: http.Client(),
    onUnauthorized: (token) => ref
        .read(authControllerProvider.notifier)
        .handleUnauthorized(token),
  );
  ref.onDispose(client.close);
  return client;
});
