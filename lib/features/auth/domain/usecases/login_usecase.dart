import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Login a user with their credentials.
/// Single Responsibility: This class does ONE thing - login.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<ApiResult<({UserEntity user, String token})>> execute(
      String identifier, String password) {
    return _repository.login(identifier, password);
  }
}
