import '../mock_developer_controls.dart';
import 'seed_data.dart';
import 'seed_models.dart';

/// Mutable, session-scoped copy of [SeedData] shared across mock
/// repositories (docs/10_DATA_FLOW.md §2).
///
/// Admin mutations in later phases edit these lists in place so the
/// storefront sees the same in-memory source of truth. [reset] restores
/// the original seed snapshot (wired to the Developer Panel).
final class MockSeedStore {
  MockSeedStore({MockDeveloperControls? controls})
    : _controls = controls { // ignore: prefer_initializing_formals
    reset();
    _controls?.registerResetListener(reset);
  }

  final MockDeveloperControls? _controls;

  late List<SeedCategory> categories;
  late List<SeedProduct> products;
  late List<SeedUser> users;
  late List<SeedOrder> orders;

  /// Restores every collection from [SeedData].
  void reset() {
    categories = List<SeedCategory>.of(SeedData.categories);
    products = List<SeedProduct>.of(SeedData.products);
    users = List<SeedUser>.of(SeedData.users);
    orders = List<SeedOrder>.of(SeedData.orders);
  }

  /// Convenience counts for the Developer Panel summary.
  Map<String, int> get counts => {
    'categories': categories.length,
    'products': products.length,
    'users': users.length,
    'orders': orders.length,
  };
}
