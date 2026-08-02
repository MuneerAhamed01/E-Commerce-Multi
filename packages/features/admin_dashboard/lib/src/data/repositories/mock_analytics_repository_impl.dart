import 'package:core/core.dart';

import '../../domain/entities/dashboard_kpi_set.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/dashboard_analytics_data_source.dart';

final class MockAnalyticsRepositoryImpl implements AnalyticsRepository {
  const MockAnalyticsRepositoryImpl(this._remote);

  final DashboardAnalyticsDataSource _remote;

  @override
  Future<Result<Failure, DashboardKpiSet>> getDashboardKpis() {
    return _guard(_remote.fetchDashboardKpis);
  }

  Future<Result<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Result.failure(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Result.failure(
        ValidationFailure(e.fieldErrors, message: e.message),
      );
    } on AppException catch (e) {
      return Result.failure(UnknownFailure(message: e.message));
    } on Object catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
