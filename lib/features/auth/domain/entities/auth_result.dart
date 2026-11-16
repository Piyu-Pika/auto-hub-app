import 'package:auto_hub_app/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

class AuthResult extends Equatable {
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserEntity user;

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn, user];
}
