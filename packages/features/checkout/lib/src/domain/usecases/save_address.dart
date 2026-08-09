import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/saved_address.dart';
import '../repositories/checkout_repository.dart';

final class SaveAddress extends UseCase<SavedAddress, SaveAddressParams> {
  const SaveAddress(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<Failure, SavedAddress>> call(SaveAddressParams params) {
    return _repository.saveAddress(
      userId: params.userId,
      address: params.address,
      makeDefault: params.makeDefault,
    );
  }
}

final class SaveAddressParams extends Equatable {
  const SaveAddressParams({
    required this.userId,
    required this.address,
    this.makeDefault = false,
  });

  final String userId;
  final Address address;
  final bool makeDefault;

  @override
  List<Object?> get props => [userId, address, makeDefault];
}
