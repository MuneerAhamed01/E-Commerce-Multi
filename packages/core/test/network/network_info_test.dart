import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('AlwaysOnlineNetworkInfo', () {
    test('always reports connected', () async {
      const NetworkInfo networkInfo = AlwaysOnlineNetworkInfo();

      expect(await networkInfo.isConnected, isTrue);
    });
  });
}
