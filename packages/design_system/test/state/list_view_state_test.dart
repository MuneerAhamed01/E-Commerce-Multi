import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListViewState equality', () {
    test('ListViewLoading instances are equal', () {
      expect(const ListViewLoading<int>(), const ListViewLoading<int>());
    });

    test('ListViewEmpty instances are equal', () {
      expect(const ListViewEmpty<int>(), const ListViewEmpty<int>());
    });

    test('ListViewLoaded compares items and pagination flags', () {
      expect(
        const ListViewLoaded<int>([1, 2, 3]),
        const ListViewLoaded<int>([1, 2, 3]),
      );
      expect(
        const ListViewLoaded<int>([1, 2, 3], hasMore: true),
        isNot(const ListViewLoaded<int>([1, 2, 3])),
      );
      expect(
        const ListViewLoaded<int>([1, 2, 3], isLoadingMore: true),
        isNot(const ListViewLoaded<int>([1, 2, 3])),
      );
    });

    test('ListViewError compares the message', () {
      expect(
        const ListViewError<int>('failed'),
        const ListViewError<int>('failed'),
      );
      expect(
        const ListViewError<int>('failed'),
        isNot(const ListViewError<int>('other')),
      );
    });
  });

  group('ListViewState pattern matching', () {
    String describe(ListViewState<int> state) {
      return switch (state) {
        ListViewLoading<int>() => 'loading',
        ListViewLoaded<int>(items: final items) => 'loaded:${items.length}',
        ListViewEmpty<int>() => 'empty',
        ListViewError<int>(message: final message) => 'error:$message',
      };
    }

    test('exhaustively switches over every state variant', () {
      expect(describe(const ListViewLoading<int>()), 'loading');
      expect(describe(const ListViewLoaded<int>([1, 2])), 'loaded:2');
      expect(describe(const ListViewEmpty<int>()), 'empty');
      expect(describe(const ListViewError<int>('oops')), 'error:oops');
    });
  });
}
