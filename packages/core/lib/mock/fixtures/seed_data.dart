import '../../shared_entities/address.dart';
import '../../shared_entities/money.dart';
import 'seed_models.dart';

/// Canonical shared seed dataset for mock repositories.
///
/// Lists are immutable snapshots; [MockSeedStore] clones them into mutable
/// in-memory state that admin mutations (later phases) can edit and that
/// [MockDeveloperControls.resetMockData] restores.
abstract final class SeedData {
  static const String currencyCode = 'USD';

  static final List<SeedCategory> categories = List<SeedCategory>.unmodifiable(
    _categories,
  );

  static final List<SeedProduct> products = List<SeedProduct>.unmodifiable(
    _buildProducts(),
  );

  static final List<SeedUser> users = List<SeedUser>.unmodifiable(
    _buildUsers(),
  );

  static final List<SeedOrder> orders = List<SeedOrder>.unmodifiable(
    _buildOrders(),
  );

  static const List<SeedCategory> _categories = [
    SeedCategory(
      id: 'cat_apparel',
      name: 'Apparel',
      slug: 'apparel',
      description: 'Clothing and everyday wear.',
      sortOrder: 1,
    ),
    SeedCategory(
      id: 'cat_footwear',
      name: 'Footwear',
      slug: 'footwear',
      description: 'Shoes, sneakers, and boots.',
      sortOrder: 2,
    ),
    SeedCategory(
      id: 'cat_accessories',
      name: 'Accessories',
      slug: 'accessories',
      description: 'Bags, belts, and small goods.',
      sortOrder: 3,
    ),
    SeedCategory(
      id: 'cat_electronics',
      name: 'Electronics',
      slug: 'electronics',
      description: 'Gadgets and home tech.',
      sortOrder: 4,
    ),
    SeedCategory(
      id: 'cat_home',
      name: 'Home & Living',
      slug: 'home-living',
      description: 'Furniture accents and home essentials.',
      sortOrder: 5,
    ),
    SeedCategory(
      id: 'cat_beauty',
      name: 'Beauty',
      slug: 'beauty',
      description: 'Skincare and personal care.',
      sortOrder: 6,
    ),
    SeedCategory(
      id: 'cat_sports',
      name: 'Sports & Outdoors',
      slug: 'sports-outdoors',
      description: 'Active gear and outdoor kit.',
      sortOrder: 7,
    ),
    SeedCategory(
      id: 'cat_kids',
      name: 'Kids',
      slug: 'kids',
      description: 'Children\'s apparel and toys.',
      sortOrder: 8,
    ),
    SeedCategory(
      id: 'cat_grocery',
      name: 'Grocery',
      slug: 'grocery',
      description: 'Pantry staples and snacks.',
      sortOrder: 9,
    ),
    SeedCategory(
      id: 'cat_office',
      name: 'Office',
      slug: 'office',
      description: 'Desk and workspace supplies.',
      sortOrder: 10,
    ),
    SeedCategory(
      id: 'cat_apparel_tops',
      name: 'Tops',
      slug: 'apparel-tops',
      description: 'T-shirts, shirts, and knits.',
      parentId: 'cat_apparel',
      sortOrder: 1,
    ),
    SeedCategory(
      id: 'cat_apparel_bottoms',
      name: 'Bottoms',
      slug: 'apparel-bottoms',
      description: 'Pants, shorts, and skirts.',
      parentId: 'cat_apparel',
      sortOrder: 2,
    ),
    SeedCategory(
      id: 'cat_electronics_phones',
      name: 'Phones',
      slug: 'electronics-phones',
      description: 'Smartphones and feature phones.',
      parentId: 'cat_electronics',
      sortOrder: 1,
    ),
    SeedCategory(
      id: 'cat_electronics_phones_cases',
      name: 'Phone Cases',
      slug: 'electronics-phones-cases',
      description: 'Protective cases and skins.',
      parentId: 'cat_electronics_phones',
      sortOrder: 1,
    ),
    SeedCategory(
      id: 'cat_electronics_audio',
      name: 'Audio',
      slug: 'electronics-audio',
      description: 'Headphones, earbuds, and speakers.',
      parentId: 'cat_electronics',
      sortOrder: 2,
    ),
    SeedCategory(
      id: 'cat_home_kitchen',
      name: 'Kitchen',
      slug: 'home-kitchen',
      description: 'Cookware and tableware.',
      parentId: 'cat_home',
      sortOrder: 1,
    ),
    SeedCategory(
      id: 'cat_sports_camping',
      name: 'Camping',
      slug: 'sports-camping',
      description: 'Tents, packs, and trail gear.',
      parentId: 'cat_sports',
      sortOrder: 1,
    ),
  ];

  static const List<String> _productAdjectives = [
    'Classic',
    'Premium',
    'Everyday',
    'Urban',
    'Trail',
    'Coastal',
    'Minimal',
    'Heritage',
    'Studio',
    'Summit',
    'Nordic',
    'Atlas',
  ];

  static const List<String> _productNouns = [
    'Tee',
    'Hoodie',
    'Sneaker',
    'Backpack',
    'Bottle',
    'Lamp',
    'Watch',
    'Jacket',
    'Cap',
    'Socks',
    'Mug',
    'Notebook',
    'Charger',
    'Speaker',
    'Mat',
    'Towel',
  ];

  static List<SeedProduct> _buildProducts() {
    final categoryIds = _categories
        .where((c) => c.parentId == null)
        .map((c) => c.id)
        .toList(growable: false);

    final products = <SeedProduct>[];
    var index = 1;
    for (final adjective in _productAdjectives) {
      for (final noun in _productNouns) {
        final idNum = index.toString().padLeft(3, '0');
        final categoryId = categoryIds[(index - 1) % categoryIds.length];
        final priceMinor = 999 + ((index * 137) % 15000);
        products.add(
          SeedProduct(
            id: 'prod_$idNum',
            name: '$adjective $noun',
            slug: '${adjective.toLowerCase()}-${noun.toLowerCase()}-$idNum',
            categoryId: categoryId,
            description:
                'A $adjective $noun designed for daily use. '
                'Seed fixture #$idNum for catalog and pagination demos.',
            price: Money(minorUnits: priceMinor, currencyCode: currencyCode),
            stock: (index * 3) % 80,
            sku: 'SKU-$idNum',
            imageUrl: 'https://cdn.example.com/products/$idNum.jpg',
            isFeatured: index % 7 == 0,
            rating: 3.5 + ((index % 15) / 10),
            reviewCount: (index * 5) % 240,
          ),
        );
        index++;
      }
    }
    // 12 adjectives × 16 nouns = 192 products — plenty for pagination.
    return products;
  }

  static List<SeedUser> _buildUsers() {
    const firstNames = [
      'Ava',
      'Noah',
      'Mia',
      'Liam',
      'Zoe',
      'Ethan',
      'Ivy',
      'Owen',
      'Luna',
      'Kai',
      'Nora',
      'Eli',
      'Aria',
      'Leo',
      'Ruby',
      'Finn',
      'Chloe',
      'Jude',
      'Hazel',
      'Theo',
      'Willow',
      'Miles',
      'Piper',
      'Asher',
    ];
    const lastNames = [
      'Nguyen',
      'Patel',
      'Garcia',
      'Kim',
      'Silva',
      'Hassan',
      'Brooks',
      'Okoye',
      'Chen',
      'Murphy',
      'Ibrahim',
      'Rossi',
    ];

    final users = <SeedUser>[
      const SeedUser(
        id: 'user_admin_01',
        email: 'admin@example.com',
        displayName: 'Platform Admin',
        role: 'admin',
        phone: '+1-555-0100',
      ),
      const SeedUser(
        id: 'user_support_01',
        email: 'support@example.com',
        displayName: 'Support Agent',
        role: 'support',
        phone: '+1-555-0101',
      ),
    ];

    for (var i = 0; i < 24; i++) {
      final first = firstNames[i % firstNames.length];
      final last = lastNames[i % lastNames.length];
      final n = (i + 1).toString().padLeft(2, '0');
      users.add(
        SeedUser(
          id: 'user_cust_$n',
          email: '${first.toLowerCase()}.${last.toLowerCase()}$n@example.com',
          displayName: '$first $last',
          role: 'customer',
          phone: '+1-555-01${n.padLeft(2, '0')}',
          isActive: i % 11 != 0,
        ),
      );
    }
    return users;
  }

  static const List<String> _orderStatuses = [
    'pending',
    'paid',
    'shipped',
    'delivered',
    'cancelled',
  ];

  static List<SeedOrder> _buildOrders() {
    final customers = _buildUsers()
        .where((u) => u.role == 'customer')
        .toList(growable: false);
    final catalog = _buildProducts();
    final orders = <SeedOrder>[];

    for (var i = 1; i <= 48; i++) {
      final customer = customers[(i - 1) % customers.length];
      final productA = catalog[(i * 3) % catalog.length];
      final productB = catalog[(i * 7 + 11) % catalog.length];
      final qtyA = 1 + (i % 3);
      final qtyB = 1 + ((i + 1) % 2);
      final items = [
        SeedOrderItem(
          productId: productA.id,
          productName: productA.name,
          quantity: qtyA,
          unitPrice: productA.price,
        ),
        SeedOrderItem(
          productId: productB.id,
          productName: productB.name,
          quantity: qtyB,
          unitPrice: productB.price,
        ),
      ];
      final subtotal = items.fold<Money>(
        Money.zero(currencyCode),
        (sum, item) => sum + item.lineTotal,
      );
      final shipping = Money(
        minorUnits: i % 5 == 0 ? 0 : 599,
        currencyCode: currencyCode,
      );
      final tax = Money(
        minorUnits: (subtotal.minorUnits * 0.08).round(),
        currencyCode: currencyCode,
      );
      final total = subtotal + shipping + tax;
      final n = i.toString().padLeft(4, '0');
      final day = ((i % 28) + 1).toString().padLeft(2, '0');
      final month = ((i % 12) + 1).toString().padLeft(2, '0');

      orders.add(
        SeedOrder(
          id: 'order_$n',
          orderNumber: 'WL-$n',
          customerId: customer.id,
          status: _orderStatuses[(i - 1) % _orderStatuses.length],
          createdAtIso:
              '2026-$month-${day}T10:${(i % 60).toString().padLeft(2, '0')}:00Z',
          items: items,
          shippingAddress: Address(
            line1: '$i Market Street',
            city: i.isEven ? 'Austin' : 'Seattle',
            state: i.isEven ? 'TX' : 'WA',
            postalCode: i.isEven ? '78701' : '98101',
            countryCode: 'US',
            line2: i % 4 == 0 ? 'Suite ${100 + i}' : null,
          ),
          subtotal: subtotal,
          shipping: shipping,
          tax: tax,
          total: total,
        ),
      );
    }
    return orders;
  }
}
