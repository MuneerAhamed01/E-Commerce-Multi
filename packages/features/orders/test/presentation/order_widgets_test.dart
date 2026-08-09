import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';

TenantConfig _testTenant() {
  return TenantConfig(
    tenantId: 'test',
    displayName: 'Test',
    branding: const BrandingTokens(
      primaryColorHex: '#0B6E4F',
      secondaryColorHex: '#08A045',
      logoAssetPath: 'assets/logo.png',
      fontFamily: 'Roboto',
    ),
    copy: const CopyOverrides.empty(),
    featureFlags: FeatureFlagSet.allEnabled(),
    defaultLocale: 'en_US',
    supportEmail: 'support@test.example',
    allowGuestBrowsing: true,
    allowGuestCart: true,
  );
}

Order _sampleOrder({OrderStatus status = OrderStatus.placed}) {
  return Order(
    id: 'ord_demo',
    orderNumber: 'WL-DEMO',
    customerId: 'user_cust_02',
    status: status,
    createdAt: DateTime.utc(2026, 8, 1, 10),
    items: const [
      OrderLineItem(
        productId: 'p1',
        productName: 'Demo Product',
        quantity: 2,
        unitPrice: Money(minorUnits: 1500, currencyCode: 'USD'),
      ),
    ],
    shippingAddress: const Address(
      line1: '1 Market St',
      city: 'Austin',
      state: 'TX',
      postalCode: '78701',
      countryCode: 'US',
      label: 'Home',
    ),
    subtotal: const Money(minorUnits: 3000, currencyCode: 'USD'),
    shipping: const Money(minorUnits: 599, currencyCode: 'USD'),
    tax: Money.zero('USD'),
    total: const Money(minorUnits: 3599, currencyCode: 'USD'),
  );
}

void main() {
  testWidgets('order list tile and badge render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(_testTenant()),
        home: Scaffold(
          body: OrderListTile(order: _sampleOrder(), onTap: () {}),
        ),
      ),
    );

    expect(find.text('WL-DEMO'), findsOneWidget);
    expect(find.byType(OrderStatusBadge), findsOneWidget);
    expect(find.text('Placed'), findsOneWidget);
  });

  testWidgets('tracking timeline renders chronologically labeled events', (
    tester,
  ) async {
    final events = [
      OrderTrackingEvent(
        id: 'e1',
        status: OrderStatus.placed,
        title: 'Order placed',
        occurredAt: DateTime.utc(2026, 8, 1, 10),
      ),
      OrderTrackingEvent(
        id: 'e2',
        status: OrderStatus.delivered,
        title: 'Delivered',
        description: 'At the door',
        occurredAt: DateTime.utc(2026, 8, 5, 10),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(_testTenant()),
        home: Scaffold(body: OrderTrackingTimeline(events: events)),
      ),
    );

    expect(find.text('Order placed'), findsWidgets);
    expect(find.text('At the door'), findsOneWidget);
    expect(find.byType(OrderStatusBadge), findsNWidgets(2));
    expect(find.byType(OrderTrackingTimeline), findsOneWidget);
  });

  testWidgets('status badge renders label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(_testTenant()),
        home: const Scaffold(
          body: OrderStatusBadge(status: OrderStatus.processing),
        ),
      ),
    );
    expect(find.text('Processing'), findsOneWidget);
  });
}
