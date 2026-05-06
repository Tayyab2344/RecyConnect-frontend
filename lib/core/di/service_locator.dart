import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/domain/usecases/password_usecases.dart';
import '../../features/auth/domain/usecases/profile_usecases.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/listing/domain/repositories/listing_repository.dart';
import '../../features/listing/data/repositories/listing_repository_impl.dart';

import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/order/data/repositories/order_repository_impl.dart';

import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';

import '../services/app_service.dart';
import '../services/report_service.dart';
import '../services/batch_service.dart';

/// Global service locator instance.
/// Access via: `sl<SomeType>()` anywhere in the app.
final GetIt sl = GetIt.instance;

/// Initialize all dependencies.
/// Call this once in main() before runApp().
Future<void> initDependencies() async {
  // ─── Auth Feature ────────────────────────────────────────

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource());
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource());

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => FetchProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl<AuthRepository>()));

  // Presentation (Provider) - Singleton so all consumers share the same state
  sl.registerLazySingleton(() => AuthProvider(
        loginUseCase: sl<LoginUseCase>(),
        registerUseCase: sl<RegisterUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
        verifyOtpUseCase: sl<VerifyOtpUseCase>(),
        resendOtpUseCase: sl<ResendOtpUseCase>(),
        forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
        resetPasswordUseCase: sl<ResetPasswordUseCase>(),
        changePasswordUseCase: sl<ChangePasswordUseCase>(),
        fetchProfileUseCase: sl<FetchProfileUseCase>(),
        updateProfileUseCase: sl<UpdateProfileUseCase>(),
        deleteAccountUseCase: sl<DeleteAccountUseCase>(),
        repository: sl<AuthRepository>(),
      ));

  // ─── Listing Feature ─────────────────────────────────────

  sl.registerLazySingleton<ListingRepository>(
      () => ListingRepositoryImpl());

  // ─── Order Feature ───────────────────────────────────────

  sl.registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl());

  // ─── Payment Feature ─────────────────────────────────────

  sl.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl());

  // ─── System & App Services ───────────────────────────────

  sl.registerLazySingleton(() => AppService());
  sl.registerLazySingleton(() => ReportService());
  sl.registerLazySingleton(() => BatchService());
}
