import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:search/src/data/mock/search_matcher.dart';
import 'package:search/src/domain/entities/search_filter.dart';
import 'package:search/src/domain/entities/sort_option.dart';

void main() {
  Product product({
    required String id,
    required String name,
    String description = 'A product description',
    String categoryId = 'cat_apparel',
    int priceMinor = 3000,
    int stock = 5,
    double rating = 4.0,
  }) {
    return Product(
      id: id,
      name: name,
      slug: name.toLowerCase().replaceAll(' ', '-'),
      description: description,
      categoryId: categoryId,
      images: const [],
      variants: [
        ProductVariant(
          id: '${id}_v',
          productId: id,
          label: 'Default',
          sku: 'SKU-$id',
          price: Money(minorUnits: priceMinor, currencyCode: 'USD'),
          stock: stock,
        ),
      ],
      rating: rating,
      reviewCount: 10,
    );
  }

  group('SearchMatcher.query', () {
    test('matches name case-insensitively', () {
      final p = product(id: '1', name: 'Classic Jacket');
      expect(SearchMatcher.matchesQuery(p, 'classic'), isTrue);
      expect(SearchMatcher.matchesQuery(p, 'JACKET'), isTrue);
      expect(SearchMatcher.matchesQuery(p, 'wireless'), isFalse);
    });

    test('matches description', () {
      final p = product(
        id: '1',
        name: 'Item',
        description: 'Designed for daily wireless use',
      );
      expect(SearchMatcher.matchesQuery(p, 'wireless'), isTrue);
    });
  });

  group('SearchMatcher.filter AND', () {
    final catalog = [
      product(
        id: 'prod_001',
        name: 'A',
        priceMinor: 2000,
        stock: 0,
        rating: 3.5,
      ),
      product(
        id: 'prod_002',
        name: 'B',
        priceMinor: 4000,
        stock: 3,
        rating: 4.5,
      ),
      product(
        id: 'prod_003',
        name: 'C',
        categoryId: 'cat_electronics',
        priceMinor: 4000,
        stock: 3,
        rating: 4.5,
      ),
    ];

    test('ANDs category + inStock + minRating + price', () {
      const filter = SearchFilter(
        categoryId: 'cat_apparel',
        inStockOnly: true,
        minRating: 4.0,
        minPriceMinor: 2500,
        maxPriceMinor: 5000,
      );
      final matched = SearchMatcher.apply(
        source: catalog,
        query: '',
        filter: filter,
        sort: SortOption.relevance,
      );
      expect(matched.map((p) => p.id), ['prod_002']);
    });

    test('empty filter keeps all query matches', () {
      final matched = SearchMatcher.apply(
        source: catalog,
        query: '',
        filter: SearchFilter.empty,
        sort: SortOption.priceAsc,
      );
      expect(matched.map((p) => p.id), ['prod_001', 'prod_002', 'prod_003']);
    });
  });

  group('SearchMatcher.sort', () {
    final catalog = [
      product(id: 'prod_010', name: 'Zebra', priceMinor: 5000, rating: 3.0),
      product(
        id: 'prod_020',
        name: 'Alpha shoes',
        priceMinor: 1000,
        rating: 5.0,
      ),
      product(id: 'prod_015', name: 'Shoes deluxe'),
    ];

    test('priceAsc / priceDesc', () {
      final asc = SearchMatcher.apply(
        source: catalog,
        query: '',
        filter: SearchFilter.empty,
        sort: SortOption.priceAsc,
      );
      expect(asc.map((p) => p.id), ['prod_020', 'prod_015', 'prod_010']);

      final desc = SearchMatcher.apply(
        source: catalog,
        query: '',
        filter: SearchFilter.empty,
        sort: SortOption.priceDesc,
      );
      expect(desc.map((p) => p.id), ['prod_010', 'prod_015', 'prod_020']);
    });

    test('newest uses numeric id suffix', () {
      final newest = SearchMatcher.apply(
        source: catalog,
        query: '',
        filter: SearchFilter.empty,
        sort: SortOption.newest,
      );
      expect(newest.map((p) => p.id), ['prod_020', 'prod_015', 'prod_010']);
    });

    test('rating descending', () {
      final byRating = SearchMatcher.apply(
        source: catalog,
        query: '',
        filter: SearchFilter.empty,
        sort: SortOption.rating,
      );
      expect(byRating.map((p) => p.id), ['prod_020', 'prod_015', 'prod_010']);
    });

    test('relevance prefers name starts-with', () {
      final byRelevance = SearchMatcher.apply(
        source: catalog,
        query: 'shoes',
        filter: SearchFilter.empty,
        sort: SortOption.relevance,
      );
      expect(byRelevance.first.id, 'prod_015');
    });
  });
}
