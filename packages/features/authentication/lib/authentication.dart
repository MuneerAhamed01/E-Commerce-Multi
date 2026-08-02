/// Authentication feature — session identity for storefront and admin apps.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
library;

export 'src/data/mock/auth_demo_credentials.dart';
export 'src/domain/entities/auth_session.dart';
export 'src/domain/entities/user.dart';
export 'src/domain/repositories/auth_repository.dart';
export 'src/domain/usecases/get_current_user.dart';
export 'src/domain/usecases/get_onboarding_seen.dart';
export 'src/domain/usecases/login_user.dart';
export 'src/domain/usecases/logout_user.dart';
export 'src/domain/usecases/refresh_session.dart';
export 'src/domain/usecases/register_user.dart';
export 'src/domain/usecases/request_password_reset.dart';
export 'src/domain/usecases/reset_password.dart';
export 'src/domain/usecases/restore_session.dart';
export 'src/domain/usecases/set_onboarding_seen.dart';
export 'src/domain/usecases/verify_otp.dart';
export 'src/injection/authentication_injection.dart';
export 'src/presentation/bloc/auth_bloc.dart';
export 'src/presentation/cubit/forgot_password_cubit.dart';
export 'src/presentation/cubit/login_cubit.dart';
export 'src/presentation/cubit/otp_cubit.dart';
export 'src/presentation/cubit/register_cubit.dart';
export 'src/presentation/cubit/reset_password_cubit.dart';
export 'src/presentation/cubit/splash_cubit.dart';
export 'src/presentation/routing/auth_routes.dart';
export 'src/presentation/routing/auth_session_listenable.dart';
export 'src/presentation/routing/auth_session_mapper.dart';
export 'src/presentation/screens/forgot_password_screen.dart';
export 'src/presentation/screens/login_screen.dart';
export 'src/presentation/screens/onboarding_screen.dart';
export 'src/presentation/screens/otp_verification_screen.dart';
export 'src/presentation/screens/register_screen.dart';
export 'src/presentation/screens/reset_password_screen.dart';
export 'src/presentation/screens/splash_screen.dart';
