import 'package:ditonton/common/ssl_pinning.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SSLPinning', () {
    test('should return an http.Client backed by IOClient', () async {
      final client = await SSLPinning.client;

      expect(client, isA<http.Client>());
      expect(client, isA<IOClient>());

      client.close();
    });

    test('should build a new client on every call', () async {
      final first = await SSLPinning.client;
      final second = await SSLPinning.client;

      expect(identical(first, second), isFalse);

      first.close();
      second.close();
    });
  });
}
