import '../repositories/auth_repository.dart';

/// UseCase: Logout the current user.
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Performs server-side logout then clears local session.
  Future<void> execute() async {
    await _repository.logoutFromServer();
    await _repository.clearSession();
  }

  /// Clears local session only (no server call).
  Future<void> executeLocal() async {
    await _repository.clearSession();
  }
}
