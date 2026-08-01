import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('PaginatedResult', () {
    test('empty() has no items, no cursor, and zero total count', () {
      const result = PaginatedResult<int>.empty();

      expect(result.items, isEmpty);
      expect(result.isEmpty, isTrue);
      expect(result.hasNextPage, isFalse);
      expect(result.totalCount, 0);
    });

    test('hasNextPage is true only when a cursor is present', () {
      const withCursor = PaginatedResult<int>(
        items: [1, 2],
        nextPageCursor: 'page-2',
      );
      const withoutCursor = PaginatedResult<int>(items: [1, 2]);

      expect(withCursor.hasNextPage, isTrue);
      expect(withoutCursor.hasNextPage, isFalse);
    });

    test('totalCount is nullable and distinct from zero', () {
      const unknownTotal = PaginatedResult<int>(items: [1]);
      const knownZeroTotal = PaginatedResult<int>(items: [], totalCount: 0);

      expect(unknownTotal.totalCount, isNull);
      expect(knownZeroTotal.totalCount, 0);
    });

    test('supports value equality', () {
      const a = PaginatedResult<int>(
        items: [1, 2],
        nextPageCursor: 'c',
        totalCount: 10,
      );
      const b = PaginatedResult<int>(
        items: [1, 2],
        nextPageCursor: 'c',
        totalCount: 10,
      );
      const c = PaginatedResult<int>(
        items: [1, 2],
        nextPageCursor: 'other',
        totalCount: 10,
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
