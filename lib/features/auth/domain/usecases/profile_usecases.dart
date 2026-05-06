import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Fetch the authenticated user's profile.
class FetchProfileUseCase {
  final AuthRepository _repository;

  FetchProfileUseCase(this._repository);

  Future<ApiResult<UserEntity>> execute() {
    return _repository.fetchProfile();
  }
}

/// UseCase: Update the authenticated user's profile.
class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<ApiResult<UserEntity>> execute(
      Map<String, dynamic> updateData, XFile? profileImage) {
    return _repository.updateProfile(updateData, profileImage);
  }
}

/// UseCase: Delete the user's account.
class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<ApiResult<String>> execute(String password, {String? reason}) {
    return _repository.deleteAccount(password, reason: reason);
  }
}
