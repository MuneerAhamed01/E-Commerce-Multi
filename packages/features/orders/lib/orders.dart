/// Post-purchase order tracking and lifecycle management for the customer.
///
/// Phase 15.1 (domain/data) is pulled forward for Phase 14.4 PlaceOrder.
/// Full history/detail UI ships in Phase 15.2+.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
library;

export 'src/domain/entities/order.dart';
export 'src/domain/entities/order_line_item.dart';
export 'src/domain/entities/order_status.dart';
export 'src/domain/repositories/order_repository.dart';
export 'src/domain/usecases/create_order.dart';
export 'src/domain/usecases/get_order.dart';
export 'src/domain/usecases/get_orders.dart';
export 'src/injection/orders_injection.dart';
