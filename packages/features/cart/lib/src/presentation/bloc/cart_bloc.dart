import 'dart:async';

import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/promo_definition.dart';
import '../../domain/pricing/cart_pricing_engine.dart';
import '../../domain/promo/cart_promo_catalog.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/apply_promo_code.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/usecases/get_cart_summary.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/remove_promo_code.dart';
import '../../domain/usecases/update_cart_item_quantity.dart';
import '../../injection/cart_injection.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// App-wide cart lifecycle (lazy singleton via DI).
final class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required GetCartSummary getCartSummary,
    required AddToCart addToCart,
    required UpdateCartItemQuantity updateCartItemQuantity,
    required RemoveFromCart removeFromCart,
    required ClearCart clearCart,
    required ApplyPromoCode applyPromoCode,
    required RemovePromoCode removePromoCode,
    required CartRepository cartRepository,
    required AuthBloc authBloc,
    Map<String, PromoDefinition>? promoCatalog,
    DateTime Function()? clock,
    // ignore: prefer_initializing_formals
  }) : _getCartSummary = getCartSummary,
       // ignore: prefer_initializing_formals
       _addToCart = addToCart,
       // ignore: prefer_initializing_formals
       _updateCartItemQuantity = updateCartItemQuantity,
       // ignore: prefer_initializing_formals
       _removeFromCart = removeFromCart,
       // ignore: prefer_initializing_formals
       _clearCart = clearCart,
       // ignore: prefer_initializing_formals
       _applyPromoCode = applyPromoCode,
       // ignore: prefer_initializing_formals
       _removePromoCode = removePromoCode,
       // ignore: prefer_initializing_formals
       _cartRepository = cartRepository,
       // ignore: prefer_initializing_formals
       _authBloc = authBloc,
       _promoCatalog =
           promoCatalog ?? CartPromoCatalog.definitions(clock: clock),
       _clock = clock ?? DateTime.now,
       super(const CartInitial()) {
    on<CartStarted>(_onStarted);
    on<CartRetried>(_onRetried);
    on<CartItemAdded>(_onItemAdded);
    on<CartQuantityChanged>(_onQuantityChanged);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
    on<CartPromoApplied>(_onPromoApplied);
    on<CartPromoRemoved>(_onPromoRemoved);
    on<CartCheckoutPressed>(_onCheckoutPressed);

    _authSub = _authBloc.stream.listen(_onAuthState);
    add(const CartStarted());
  }

  final GetCartSummary _getCartSummary;
  final AddToCart _addToCart;
  final UpdateCartItemQuantity _updateCartItemQuantity;
  final RemoveFromCart _removeFromCart;
  final ClearCart _clearCart;
  final ApplyPromoCode _applyPromoCode;
  final RemovePromoCode _removePromoCode;
  final CartRepository _cartRepository;
  final AuthBloc _authBloc;
  final Map<String, PromoDefinition> _promoCatalog;
  final DateTime Function() _clock;

  StreamSubscription<AuthState>? _authSub;
  String? _previousUserId;

  String get _ownerId {
    final auth = _authBloc.state;
    if (auth is AuthAuthenticated) {
      return auth.session.user.id;
    }
    return cartGuestOwnerId;
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    await _load(emit);
  }

  Future<void> _onRetried(CartRetried event, Emitter<CartState> emit) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<CartState> emit) async {
    final previous = state is CartLoaded ? state as CartLoaded : null;
    emit(CartLoading(previous: previous));
    final result = await _getCartSummary(GetCartSummaryParams(_ownerId));
    result.fold(
      onFailure: (failure) {
        emit(
          CartError(
            failure.message ?? 'Could not load cart',
            itemCountHint: previous?.itemCount ?? 0,
          ),
        );
      },
      onSuccess: (summary) {
        emit(CartLoaded(summary: summary));
      },
    );
  }

  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final result = await _addToCart(
      AddToCartParams(
        ownerId: _ownerId,
        productId: event.productId,
        variantId: event.variantId,
        quantity: event.quantity,
      ),
    );
    await result.fold(
      onFailure: (failure) async {
        final message = _mapMutationFailure(failure);
        final current = state;
        if (current is CartLoaded) {
          emit(current.copyWith(statusMessage: message));
        } else {
          emit(CartError(message));
        }
      },
      onSuccess: (_) async {
        await _reloadKeepingMessages(emit, statusMessage: 'Added to cart');
      },
    );
  }

  Future<void> _onQuantityChanged(
    CartQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    final result = await _updateCartItemQuantity(
      UpdateCartItemQuantityParams(
        ownerId: _ownerId,
        productId: event.productId,
        variantId: event.variantId,
        quantity: event.quantity,
      ),
    );
    await result.fold(
      onFailure: (failure) async {
        final message = _mapMutationFailure(failure);
        final current = state;
        if (current is CartLoaded) {
          emit(current.copyWith(statusMessage: message));
          await _reloadKeepingMessages(emit);
        } else {
          emit(CartError(message));
        }
      },
      onSuccess: (_) async {
        await _reloadKeepingMessages(emit);
      },
    );
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final result = await _removeFromCart(
      RemoveFromCartParams(
        ownerId: _ownerId,
        productId: event.productId,
        variantId: event.variantId,
      ),
    );
    await result.fold(
      onFailure: (failure) async {
        final message = failure.message ?? 'Could not remove item';
        final current = state;
        if (current is CartLoaded) {
          emit(current.copyWith(statusMessage: message));
        }
      },
      onSuccess: (_) async {
        await _reloadKeepingMessages(emit);
      },
    );
  }

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) async {
    final result = await _clearCart(ClearCartParams(_ownerId));
    await result.fold(
      onFailure: (failure) async {
        final current = state;
        if (current is CartLoaded) {
          emit(
            current.copyWith(
              statusMessage: failure.message ?? 'Could not clear cart',
            ),
          );
        }
      },
      onSuccess: (_) async {
        await _reloadKeepingMessages(emit);
      },
    );
  }

  Future<void> _onPromoApplied(
    CartPromoApplied event,
    Emitter<CartState> emit,
  ) async {
    final current = state;
    if (current is CartLoaded) {
      emit(current.copyWith(isApplyingPromo: true, clearPromoError: true));
    }

    final result = await _applyPromoCode(
      ApplyPromoCodeParams(ownerId: _ownerId, code: event.code),
    );
    await result.fold(
      onFailure: (failure) async {
        final message = _promoMessage(failure);
        final loaded = state;
        if (loaded is CartLoaded) {
          emit(loaded.copyWith(isApplyingPromo: false, promoError: message));
        }
      },
      onSuccess: (_) async {
        await _reloadKeepingMessages(emit);
      },
    );
  }

  Future<void> _onPromoRemoved(
    CartPromoRemoved event,
    Emitter<CartState> emit,
  ) async {
    final result = await _removePromoCode(RemovePromoCodeParams(_ownerId));
    await result.fold(
      onFailure: (failure) async {
        final current = state;
        if (current is CartLoaded) {
          emit(
            current.copyWith(
              promoError: failure.message ?? 'Could not remove promo',
            ),
          );
        }
      },
      onSuccess: (_) async {
        await _reloadKeepingMessages(emit);
      },
    );
  }

  void _onCheckoutPressed(CartCheckoutPressed event, Emitter<CartState> emit) {
    // Navigation is owned by the host via CartScreen.onCheckoutNavigate.
  }

  Future<void> _onAuthState(AuthState authState) async {
    if (authState is AuthAuthenticated) {
      final userId = authState.session.user.id;
      if (_previousUserId != userId) {
        await _cartRepository.mergeGuestCart(
          guestOwnerId: cartGuestOwnerId,
          userOwnerId: userId,
        );
        _previousUserId = userId;
        if (!isClosed) {
          add(const CartStarted());
        }
      }
      return;
    }
    if (authState is AuthUnauthenticated || authState is AuthInitial) {
      _previousUserId = null;
      if (!isClosed) {
        add(const CartStarted());
      }
    }
  }

  Future<void> _reloadKeepingMessages(
    Emitter<CartState> emit, {
    String? statusMessage,
  }) async {
    final result = await _getCartSummary(GetCartSummaryParams(_ownerId));
    result.fold(
      onFailure: (failure) {
        emit(CartError(failure.message ?? 'Could not load cart'));
      },
      onSuccess: (summary) {
        emit(CartLoaded(summary: summary, statusMessage: statusMessage));
      },
    );
  }

  String _mapMutationFailure(Failure failure) {
    if (failure is InsufficientStockFailure) {
      return failure.message ??
          'Only ${failure.availableQuantity} available in stock';
    }
    if (failure is ValidationFailure) {
      return failure.message ??
          (failure.fieldErrors.isNotEmpty
              ? failure.fieldErrors.values.first
              : 'Invalid cart update');
    }
    return failure.message ?? 'Could not update cart';
  }

  String _promoMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.fieldErrors['promoCode'] ??
          failure.message ??
          'Invalid promo code';
    }
    return failure.message ?? 'Could not apply promo code';
  }

  /// Resolves pricing for a [Cart] using the local mock catalog.
  CartSummary summarize(Cart cart) {
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
