import 'package:auto_hub_app/features/auth/data/models/user_model.dart';
import 'package:auto_hub_app/features/auth/domain/entities/auth_result.dart';

class AuthResponseModel extends AuthResult {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
    required UserModel super.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 3600,
      user: UserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}
