/// Named routes and paths for the checkout wizard.
abstract final class CheckoutRoutes {
  static const String addressPath = '/checkout/address';
  static const String addressName = 'CheckoutAddressRoute';

  static const String shippingPaymentPath = '/checkout/shipping-payment';
  static const String shippingPaymentName = 'CheckoutShippingPaymentRoute';

  static const String reviewPath = '/checkout/review';
  static const String reviewName = 'CheckoutReviewRoute';

  static const String confirmationName = 'CheckoutConfirmationRoute';

  static String confirmationPath(String orderId) =>
      '/checkout/confirmation/$orderId';

  static const List<String> stepperLabels = ['Address', 'Shipping', 'Review'];
}
