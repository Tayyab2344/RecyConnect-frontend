import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Register a new user.
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<ApiResult<({String message, int? userId})>> execute(
      Map<String, dynamic> userData, Map<String, XFile> files) {
    return _repository.register(userData, files);
  }
}
