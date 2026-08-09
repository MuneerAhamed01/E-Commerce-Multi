/// Named routes and paths for customer order history/detail.
abstract final class OrderRoutes {
  static const String historyPath = '/orders';
  static const String historyName = 'OrderHistoryRoute';

  static const String detailName = 'OrderDetailRoute';
  static const String cancelName = 'OrderCancelRoute';
  static const String returnName = 'OrderReturnRoute';

  static String detailPath(String orderId) => '/orders/$orderId';

  static String cancelPath(String orderId) => '/orders/$orderId/cancel';

  static String returnPath(String orderId) => '/orders/$orderId/return';
}
