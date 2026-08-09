/// Post-purchase order tracking and lifecycle management for the customer.
///
/// Phase 15: history, detail/tracking, cancel/return (15.1 domain pulled
/// forward for checkout PlaceOrder).
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
library;

export 'src/domain/entities/order.dart';
export 'src/domain/entities/order_line_item.dart';
export 'src/domain/entities/order_status.dart';
export 'src/domain/entities/order_tracking_event.dart';
export 'src/domain/repositories/order_repository.dart';
export 'src/domain/usecases/cancel_order.dart';
export 'src/domain/usecases/create_order.dart';
export 'src/domain/usecases/get_order.dart';
export 'src/domain/usecases/get_order_tracking_events.dart';
export 'src/domain/usecases/get_orders.dart';
export 'src/domain/usecases/request_return.dart';
export 'src/injection/orders_injection.dart';
export 'src/presentation/bloc/order_detail_bloc.dart';
export 'src/presentation/bloc/order_list_bloc.dart';
export 'src/presentation/routing/order_routes.dart';
export 'src/presentation/screens/order_detail_screen.dart';
export 'src/presentation/screens/order_history_screen.dart';
export 'src/presentation/widgets/cancel_return_dialog.dart';
export 'src/presentation/widgets/order_list_tile.dart';
export 'src/presentation/widgets/order_status_badge.dart';
export 'src/presentation/widgets/order_tracking_timeline.dart';
