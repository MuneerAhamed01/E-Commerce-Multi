import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/saved_address.dart';
import '../repositories/checkout_repository.dart';

final class GetSavedAddresses
    extends UseCase<List<SavedAddress>, GetSavedAddressesParams> {
  const GetSavedAddresses(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<Failure, List<SavedAddress>>> call(
    GetSavedAddressesParams params,
  ) {
    return _repository.getSavedAddresses(params.userId);
  }
}

final class GetSavedAddressesParams extends Equatable {
  const GetSavedAddressesParams(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
