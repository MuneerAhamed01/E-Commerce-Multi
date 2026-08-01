import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('configureCoreInjection', () {
    tearDown(() async {
      if (getIt.isRegistered<AppLogger>() ||
          getIt.isRegistered<NetworkInfo>()) {
        await getIt.reset();
      }
    });

    test('registers AppLogger and NetworkInfo as resolvable singletons', () {
      configureCoreInjection();

      expect(getIt.isRegistered<AppLogger>(), isTrue);
      expect(getIt.isRegistered<NetworkInfo>(), isTrue);
      expect(getIt<AppLogger>(), isA<ConsoleAppLogger>());
      expect(getIt<NetworkInfo>(), isA<AlwaysOnlineNetworkInfo>());
    });

    test('resolves the same lazy-singleton instance on every call', () {
      configureCoreInjection();

      expect(getIt<AppLogger>(), same(getIt<AppLogger>()));
    });
  });
}
