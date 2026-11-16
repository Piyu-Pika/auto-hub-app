import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSessionChecked extends AuthEvent {
  const AuthSessionChecked();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({
    required this.email,
    required this.password,
    this.deviceId,
  });

  final String email;
  final String password;
  final String? deviceId;

  @override
  List<Object?> get props => [email, password, deviceId];
}

class AuthRegisterSubmitted extends AuthEvent {
  const AuthRegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
    this.deviceId,
    this.platform,
  });

  final String fullName;
  final String email;
  final String password;
  final String? phone;
  final String? deviceId;
  final String? platform;

  @override
  List<Object?> get props => [
        fullName,
        email,
        password,
        phone,
        deviceId,
        platform,
      ];
}

class AuthSocialSubmitted extends AuthEvent {
  const AuthSocialSubmitted({
    required this.provider,
    required this.idToken,
    this.deviceId,
  });

  final String provider;
  final String idToken;
  final String? deviceId;

  @override
  List<Object?> get props => [provider, idToken, deviceId];
}

class AuthForgotPasswordSubmitted extends AuthEvent {
  const AuthForgotPasswordSubmitted(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordSubmitted extends AuthEvent {
  const AuthResetPasswordSubmitted({
    required this.token,
    required this.newPassword,
  });

  final String token;
  final String newPassword;

  @override
  List<Object?> get props => [token, newPassword];
}

class AuthLogoutSubmitted extends AuthEvent {
  const AuthLogoutSubmitted();
}
