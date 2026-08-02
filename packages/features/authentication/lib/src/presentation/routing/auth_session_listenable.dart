import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bloc/auth_bloc.dart';

/// Bridges [AuthBloc] emissions to [GoRouter.refreshListenable].
final class AuthSessionListenable extends ChangeNotifier {
  AuthSessionListenable(AuthBloc bloc) : _bloc = bloc {
    _subscription = _bloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _bloc;
  late final StreamSubscription<AuthState> _subscription;

  AuthBloc get bloc => _bloc;

  AuthState get state => _bloc.state;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
