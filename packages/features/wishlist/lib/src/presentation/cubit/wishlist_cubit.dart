import 'dart:async';

import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:products/products.dart';

import '../../data/mock/wishlist_product_mapper.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/usecases/add_to_wishlist.dart';
import '../../domain/usecases/get_wishlist.dart';
import '../../domain/usecases/remove_from_wishlist.dart';
import 'wishlist_state.dart';

/// App-wide wishlist membership (lazy singleton via DI).
final class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit({
    required GetWishlist getWishlist,
    required AddToWishlist addToWishlist,
    required RemoveFromWishlist removeFromWishlist,
    required AuthBloc authBloc,
    MockSeedStore? seedStore,
    // Private fields can't use initializing formals with public param names.
    // ignore: prefer_initializing_formals
  }) : _getWishlist = getWishlist,
       // ignore: prefer_initializing_formals
       _addToWishlist = addToWishlist,
       // ignore: prefer_initializing_formals
       _removeFromWishlist = removeFromWishlist,
       // ignore: prefer_initializing_formals
       _authBloc = authBloc,
       // ignore: prefer_initializing_formals
       _seedStore = seedStore,
       super(const WishlistInitial()) {
    _authSub = _authBloc.stream.listen(_onAuthState);
    _onAuthState(_authBloc.state);
  }

  final GetWishlist _getWishlist;
  final AddToWishlist _addToWishlist;
  final RemoveFromWishlist _removeFromWishlist;
  final AuthBloc _authBloc;
  final MockSeedStore? _seedStore;

  StreamSubscription<AuthState>? _authSub;

  String? _pendingProductId;
  String? _pendingVariantId;

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }

  bool isInWishlist(String productId) {
    final current = state;
    return current is WishlistLoaded && current.contains(productId);
  }

  /// Queues a toggle that runs after the next successful login.
  void queueToggle({required String productId, String? variantId}) {
    _pendingProductId = productId;
    _pendingVariantId = variantId;
    final current = state;
    if (current is WishlistLoaded) {
      emit(current.copyWith(pendingProductId: productId));
    }
  }

  Future<void> toggle({required String productId, String? variantId}) async {
    final auth = _authBloc.state;
    if (auth is! AuthAuthenticated) {
      queueToggle(productId: productId, variantId: variantId);
      return;
    }

    final userId = auth.session.user.id;
    final current = state;
    final alreadyIn = current is WishlistLoaded && current.contains(productId);

    if (current is WishlistLoaded) {
      emit(current.copyWith(isToggling: true));
    }

    if (alreadyIn) {
      await remove(productId);
    } else {
      final result = await _addToWishlist(
        AddToWishlistParams(
          userId: userId,
          productId: productId,
          variantId: variantId,
        ),
      );
      await result.fold(
        onFailure: (failure) async {
          emit(
            WishlistError(
              failure.message ?? 'Could not update wishlist',
              userId: userId,
            ),
          );
          await load(userId: userId);
        },
        onSuccess: (_) async {
          await load(userId: userId);
        },
      );
    }
  }

  Future<void> remove(String productId) async {
    final auth = _authBloc.state;
    if (auth is! AuthAuthenticated) {
      return;
    }
    final userId = auth.session.user.id;
    final result = await _removeFromWishlist(
      RemoveFromWishlistParams(userId: userId, productId: productId),
    );
    await result.fold(
      onFailure: (failure) async {
        emit(
          WishlistError(
            failure.message ?? 'Could not update wishlist',
            userId: userId,
          ),
        );
        await load(userId: userId);
      },
      onSuccess: (_) async {
        await load(userId: userId);
      },
    );
  }

  Future<void> load({String? userId}) async {
    final resolvedUserId = userId ?? _currentUserId;
    if (resolvedUserId == null) {
      emit(const WishlistGuest());
      return;
    }

    emit(const WishlistLoading());
    final result = await _getWishlist(GetWishlistParams(resolvedUserId));
    await result.fold(
      onFailure: (failure) async {
        emit(
          WishlistError(
            failure.message ?? 'Could not load wishlist',
            userId: resolvedUserId,
          ),
        );
      },
      onSuccess: (items) async {
        emit(
          WishlistLoaded(
            userId: resolvedUserId,
            items: items,
            products: _resolveProducts(items),
            pendingProductId: _pendingProductId,
          ),
        );
      },
    );
  }

  Future<void> retry() => load();

  String? get _currentUserId {
    final auth = _authBloc.state;
    if (auth is AuthAuthenticated) {
      return auth.session.user.id;
    }
    return null;
  }

  Future<void> _onAuthState(AuthState authState) async {
    if (authState is AuthAuthenticated) {
      await load(userId: authState.session.user.id);
      await _flushPendingToggle();
      return;
    }
    if (authState is AuthUnauthenticated || authState is AuthInitial) {
      emit(const WishlistGuest());
    }
  }

  Future<void> _flushPendingToggle() async {
    final productId = _pendingProductId;
    if (productId == null) {
      return;
    }
    final variantId = _pendingVariantId;
    _pendingProductId = null;
    _pendingVariantId = null;
    // Guest intent is "save for later" — add only when not already present.
    if (!isInWishlist(productId)) {
      await toggle(productId: productId, variantId: variantId);
    }
  }

  Map<String, Product> _resolveProducts(List<WishlistItem> items) {
    final store =
        _seedStore ??
        (getIt.isRegistered<MockSeedStore>() ? getIt<MockSeedStore>() : null);
    if (store == null) {
      return const {};
    }
    final byId = {for (final seed in store.products) seed.id: seed};
    final map = <String, Product>{};
    for (final item in items) {
      final seed = byId[item.productId];
      if (seed != null) {
        map[item.productId] = WishlistProductMapper.fromSeed(seed);
      }
    }
    return map;
  }
}
