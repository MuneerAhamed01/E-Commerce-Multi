import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/cart.dart';
import '../entities/promo_definition.dart';
import '../pricing/cart_pricing_engine.dart';
import '../promo/cart_promo_catalog.dart';
import '../repositories/cart_repository.dart';

final class GetCartSummary extends UseCase<CartSummary, GetCartSummaryParams> {
  GetCartSummary(
    this._repository, {
    Map<String, PromoDefinition>? promoCatalog,
    DateTime Function()? clock,
  }) : _promoCatalog =
           promoCatalog ?? CartPromoCatalog.definitions(clock: clock),
       _clock = clock ?? DateTime.now;

  final CartRepository _repository;
  final Map<String, PromoDefinition> _promoCatalog;
  final DateTime Function() _clock;

  @override
  Future<Result<Failure, CartSummary>> call(GetCartSummaryParams params) async {
    final result = await _repository.getCart(params.ownerId);
    return result.map(_toSummary);
  }

  CartSummary _toSummary(Cart cart) {
    PromoDefinition? promo;
    final code = cart.appliedPromoCode;
    if (code != null) {
      final validation = PromoValidator.validate(
        rawCode: code,
        subtotal: cart.subtotal,
        catalog: _promoCatalog,
        clock: _clock,
      );
      if (validation is PromoValidationSuccess) {
        promo = validation.promo;
      }
    }
    return CartSummary(
      cart: cart,
      pricing: CartPricingEngine.compute(cart, promo: promo),
    );
  }
}

final class GetCartSummaryParams extends Equatable {
  const GetCartSummaryParams(this.ownerId);

  final String ownerId;

  @override
  List<Object?> get props => [ownerId];
}
