import 'package:flutter_test/flutter_test.dart';

import 'package:branca_dart/branca_dart.dart';

void main() {
  test('adds one to input values', () {
    final branca = Branca("3d7b5ea32875c4dcc15d32ae698e430d");
    String result = branca.encode("Try to hide some cool content here");
    print(result);

    String decoded = branca.decode(result);
    print(decoded);
  });
}
