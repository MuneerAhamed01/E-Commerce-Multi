import 'package:authentication/authentication.dart';
import 'package:cart/cart.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/checkout_session.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/usecases/calculate_shipping_cost.dart';
import '../../domain/usecases/get_checkout_payment_methods.dart';
import '../../domain/usecases/get_saved_addresses.dart';
import '../../domain/usecases/get_shipping_methods.dart';
import '../../domain/usecases/place_order.dart';
import '../../domain/usecases/save_address.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

/// Multi-step checkout wizard bloc (one instance spanning address → review).
final class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({
    required GetSavedAddresses getSavedAddresses,
    required SaveAddress saveAddress,
    required GetShippingMethods getShippingMethods,
    required CalculateShippingCost calculateShippingCost,
    required GetCheckoutPaymentMethods getCheckoutPaymentMethods,
    required GetCartSummary getCartSummary,
    required PlaceOrder placeOrder,
    required AuthBloc authBloc,
    // ignore: prefer_initializing_formals
  }) : _getSavedAddresses = getSavedAddresses,
       // ignore: prefer_initializing_formals
       _saveAddress = saveAddress,
       // ignore: prefer_initializing_formals
       _getShippingMethods = getShippingMethods,
       // ignore: prefer_initializing_formals
       _calculateShippingCost = calculateShippingCost,
       // ignore: prefer_initializing_formals
       _getCheckoutPaymentMethods = getCheckoutPaymentMethods,
       // ignore: prefer_initializing_formals
       _getCartSummary = getCartSummary,
       // ignore: prefer_initializing_formals
       _placeOrder = placeOrder,
       // ignore: prefer_initializing_formals
       _authBloc = authBloc,
       super(const CheckoutLoading()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutAddressSelected>(_onAddressSelected);
    on<CheckoutAddressSaved>(_onAddressSaved);
    on<CheckoutContinueFromAddress>(_onContinueFromAddress);
    on<CheckoutShippingSelected>(_onShippingSelected);
    on<CheckoutPaymentSelected>(_onPaymentSelected);
    on<CheckoutContinueFromShippingPayment>(_onContinueFromShippingPayment);
    on<CheckoutPlaceOrderRequested>(_onPlaceOrder);
    on<CheckoutRetried>(_onRetried);
    on<CheckoutReset>(_onReset);
  }

  final GetSavedAddresses _getSavedAddresses;
  final SaveAddress _saveAddress;
  final GetShippingMethods _getShippingMethods;
  final CalculateShippingCost _calculateShippingCost;
  final GetCheckoutPaymentMethods _getCheckoutPaymentMethods;
  final GetCartSummary _getCartSummary;
  final PlaceOrder _placeOrder;
  final AuthBloc _authBloc;

  String? _placedOrderId;
  bool _isPlacing = false;

  String? get _userId {
    final auth = _authBloc.state;
    if (auth is AuthAuthenticated) {
      return auth.session.user.id;
    }
    return null;
  }

  Future<void> _onStarted(
    CheckoutStarted event,
    Emitter<CheckoutState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRetried(
    CheckoutRetried event,
    Emitter<CheckoutState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onReset(
    CheckoutReset event,
    Emitter<CheckoutState> emit,
  ) async {
    _placedOrderId = null;
    _isPlacing = false;
    await _load(emit);
  }

  Future<void> _load(Emitter<CheckoutState> emit) async {
    emit(const CheckoutLoading());
    final userId = _userId;
    if (userId == null) {
      emit(const CheckoutError('Sign in to checkout'));
      return;
    }

    final addressesResult = await _getSavedAddresses(
      GetSavedAddressesParams(userId),
    );
    final shippingResult = await _getShippingMethods(const NoParams());
    final paymentsResult = await _getCheckoutPaymentMethods(
      GetCheckoutPaymentMethodsParams(userId),
    );
    final cartResult = await _getCartSummary(GetCartSummaryParams(userId));

    if (addressesResult.isFailure ||
        shippingResult.isFailure ||
        paymentsResult.isFailure ||
        cartResult.isFailure) {
      final message =
          addressesResult.failureOrNull?.message ??
          shippingResult.failureOrNull?.message ??
          paymentsResult.failureOrNull?.message ??
          cartResult.failureOrNull?.message ??
          'Could not load checkout';
      emit(CheckoutError(message));
      return;
    }

    final addresses = addressesResult.valueOrNull!;
    final shippingMethods = shippingResult.valueOrNull!;
    final paymentMethods = paymentsResult.valueOrNull!;
    final cartSummary = cartResult.valueOrNull!;

    if (cartSummary.cart.isEmpty) {
      emit(const CheckoutError('Your cart is empty'));
      return;
    }

    SavedAddress? defaultAddress;
    for (final address in addresses) {
      if (address.isDefault) {
        defaultAddress = address;
        break;
      }
    }
    defaultAddress ??= addresses.isEmpty ? null : addresses.first;

    final defaultShipping = shippingMethods.isEmpty
        ? null
        : shippingMethods.first;

    var defaultPayment = paymentMethods.isEmpty ? null : paymentMethods.first;
    for (final payment in paymentMethods) {
      if (payment.isDefault) {
        defaultPayment = payment;
        break;
      }
    }

    final session = CheckoutSession(
      selectedAddressId: defaultAddress?.id,
      shippingMethodId: defaultShipping?.id,
      paymentMethodId: defaultPayment?.id,
    );

    Money? shippingCost;
    String? shippingError;
    if (defaultShipping != null && defaultAddress != null) {
      final costResult = await _calculateShippingCost(
        CalculateShippingCostParams(
          methodId: defaultShipping.id,
          postalCode: defaultAddress.address.postalCode,
        ),
      );
      if (costResult.isSuccess) {
        shippingCost = costResult.valueOrNull;
      } else {
        shippingError = _failureMessage(costResult.failureOrNull);
      }
    }

    emit(
      CheckoutReady(
        session: session,
        addresses: addresses,
        shippingMethods: shippingMethods,
        paymentMethods: paymentMethods,
        cartSummary: cartSummary,
        shippingCost: shippingCost,
        shippingError: shippingError,
      ),
    );
  }

  Future<void> _onAddressSelected(
    CheckoutAddressSelected event,
    Emitter<CheckoutState> emit,
  ) async {
    final current = state;
    if (current is! CheckoutReady) {
      return;
    }
    final next = current.copyWith(
      session: current.session.copyWith(
        selectedAddressId: event.addressId,
        clearDraft: true,
      ),
      clearStepError: true,
    );
    emit(next);

    final address = next.selectedAddress;
    final methodId = next.session.shippingMethodId;
    if (address != null && methodId != null) {
      await _refreshShippingCost(emit, methodId, address.address.postalCode);
    }
  }

  Future<void> _onAddressSaved(
    CheckoutAddressSaved event,
    Emitter<CheckoutState> emit,
  ) async {
    final current = state;
    if (current is! CheckoutReady) {
      return;
    }
    final userId = _userId;
    if (userId == null) {
      return;
    }

    final result = await _saveAddress(
      SaveAddressParams(userId: userId, address: event.address),
    );
    await result.fold(
      onFailure: (failure) async {
        emit(
          current.copyWith(
            stepError: failure.message ?? 'Could not save address',
          ),
        );
      },
      onSuccess: (saved) async {
        final addresses = [...current.addresses, saved];
        final next = current.copyWith(
          addresses: addresses,
          session: current.session.copyWith(
            selectedAddressId: saved.id,
            clearDraft: true,
          ),
          clearStepError: true,
        );
        emit(next);
        final methodId = next.session.shippingMethodId;
        if (methodId != null) {
          await _refreshShippingCost(emit, methodId, saved.address.postalCode);
        }
      },
    );
  }

  void _onContinueFromAddress(
    CheckoutContinueFromAddress event,
    Emitter<CheckoutState> emit,
  ) {
    final current = state;
    if (current is! CheckoutReady) {
      return;
    }
    if (!current.session.hasAddress) {
      emit(current.copyWith(stepError: 'Select or add a shipping address'));
      return;
    }
    emit(current.copyWith(clearStepError: true));
  }

  Future<void> _onShippingSelected(
    CheckoutShippingSelected event,
    Emitter<CheckoutState> emit,
  ) async {
    final current = state;
    if (current is! CheckoutReady) {
      return;
    }
    final next = current.copyWith(
      session: current.session.copyWith(shippingMethodId: event.methodId),
      clearStepError: true,
      clearShippingError: true,
    );
    emit(next);
    final postal = next.effectiveAddress?.postalCode;
    if (postal != null) {
      await _refreshShippingCost(emit, event.methodId, postal);
    }
  }

  void _onPaymentSelected(
    CheckoutPaymentSelected event,
    Emitter<CheckoutState> emit,
  ) {
    final current = state;
    if (current is! CheckoutReady) {
      return;
    }
    emit(
      current.copyWith(
        session: current.session.copyWith(paymentMethodId: event.methodId),
        clearStepError: true,
      ),
    );
  }

  void _onContinueFromShippingPayment(
    CheckoutContinueFromShippingPayment event,
    Emitter<CheckoutState> emit,
  ) {
    final current = state;
    if (current is! CheckoutReady) {
      return;
    }
    if (!current.session.hasShipping || !current.session.hasPayment) {
      emit(
        current.copyWith(
          stepError: 'Select a shipping method and payment method',
        ),
      );
      return;
    }
    if (current.shippingError != null || current.shippingCost == null) {
      emit(
        current.copyWith(
          stepError: current.shippingError ?? 'Shipping is unavailable',
        ),
      );
      return;
    }
    emit(current.copyWith(clearStepError: true));
  }

  Future<void> _onPlaceOrder(
    CheckoutPlaceOrderRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    // Idempotency: ignore while placing or after a successful place.
    if (_isPlacing || _placedOrderId != null || state is CheckoutPlaced) {
      return;
    }
    final current = state;
    if (current is! CheckoutReady) {
      return;
    }
    final userId = _userId;
    if (userId == null) {
      emit(const CheckoutError('Sign in to checkout'));
      return;
    }

    _isPlacing = true;
    emit(CheckoutPlacing(current));

    final result = await _placeOrder(
      PlaceOrderParams(
        customerId: userId,
        session: current.session,
        addresses: current.addresses,
        shippingMethod: current.selectedShipping,
        paymentMethod: current.selectedPayment,
      ),
    );

    await result.fold(
      onFailure: (failure) async {
        _isPlacing = false;
        emit(
          current.copyWith(
            stepError: failure.message ?? 'Could not place order',
          ),
        );
      },
      onSuccess: (order) async {
        _placedOrderId = order.id;
        _isPlacing = false;
        emit(CheckoutPlaced(orderId: order.id, orderNumber: order.orderNumber));
      },
    );
  }

  Future<void> _refreshShippingCost(
    Emitter<CheckoutState> emit,
    String methodId,
    String postalCode,
  ) async {
    final result = await _calculateShippingCost(
      CalculateShippingCostParams(methodId: methodId, postalCode: postalCode),
    );
    final latest = state;
    if (latest is! CheckoutReady) {
      return;
    }
    await result.fold(
      onFailure: (failure) async {
        emit(
          latest.copyWith(
            clearShippingCost: true,
            shippingError: _failureMessage(failure),
          ),
        );
      },
      onSuccess: (cost) async {
        emit(latest.copyWith(shippingCost: cost, clearShippingError: true));
      },
    );
  }

  String _failureMessage(Failure? failure) {
    if (failure == null) {
      return 'Shipping unavailable';
    }
    if (failure is ValidationFailure && failure.fieldErrors.isNotEmpty) {
      return failure.fieldErrors.values.first;
    }
    return failure.message ?? 'Shipping unavailable';
  }
}
