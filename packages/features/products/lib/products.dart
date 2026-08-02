/// Core catalog: browse, view detail, read/write reviews.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
library;

export 'src/domain/entities/product.dart';
export 'src/domain/entities/product_filter.dart';
export 'src/domain/entities/product_image.dart';
export 'src/domain/entities/product_page_request.dart';
export 'src/domain/entities/product_variant.dart';
export 'src/domain/entities/review.dart';
export 'src/domain/repositories/product_repository.dart';
export 'src/domain/usecases/get_product_detail.dart';
export 'src/domain/usecases/get_product_reviews.dart';
export 'src/domain/usecases/get_products.dart';
export 'src/domain/usecases/get_related_products.dart';
export 'src/domain/usecases/submit_product_review.dart';
export 'src/injection/products_injection.dart';
export 'src/presentation/bloc/product_detail_bloc.dart';
export 'src/presentation/bloc/product_list_bloc.dart';
export 'src/presentation/cubit/reviews_cubit.dart';
export 'src/presentation/routing/product_routes.dart';
export 'src/presentation/screens/product_detail_screen.dart';
export 'src/presentation/screens/product_list_screen.dart';
export 'src/presentation/widgets/product_card.dart';
export 'src/presentation/widgets/product_gallery.dart';
export 'src/presentation/widgets/product_grid.dart';
export 'src/presentation/widgets/rating_summary.dart';
export 'src/presentation/widgets/review_list.dart';
export 'src/presentation/widgets/review_submission_form.dart';
export 'src/presentation/widgets/variant_selector.dart';
