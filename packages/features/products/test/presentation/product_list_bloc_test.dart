import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

import '../helpers/products_test_harness.dart';

void main() {
  late ProductsTestHarness harness;

  setUp(() {
    harness = ProductsTestHarness.create();
  });

  blocTest<ProductListBloc, ProductListState>(
    'ProductListStarted emits loading then loaded page',
    build: () => harness.createListBloc(),
    act: (bloc) => bloc.add(const ProductListStarted()),
    expect: () => [
      const ProductListLoading(),
      isA<ProductListLoaded>().having(
        (s) => s.products.length,
        'page size',
        ProductPageRequest.defaultPageSize,
      ),
    ],
  );

  blocTest<ProductListBloc, ProductListState>(
    'ProductListLoadMore appends next page',
    build: () => harness.createListBloc(),
    act: (bloc) async {
      bloc.add(const ProductListStarted());
      await bloc.stream.firstWhere((s) => s is ProductListLoaded);
      bloc.add(const ProductListLoadMore());
    },
    expect: () => [
      const ProductListLoading(),
      isA<ProductListLoaded>().having(
        (s) => s.isLoadingMore,
        'loadingMore',
        false,
      ),
      isA<ProductListLoaded>().having(
        (s) => s.isLoadingMore,
        'loadingMore',
        true,
      ),
      isA<ProductListLoaded>().having(
        (s) => s.products.length,
        'two pages',
        ProductPageRequest.defaultPageSize * 2,
      ),
    ],
  );
}
