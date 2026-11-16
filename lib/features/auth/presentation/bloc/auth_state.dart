import 'package:auto_hub_app/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  const AuthError({
    required this.message,
    this.field,
    this.statusCode,
  });

  final String message;
  final String? field;
  final int? statusCode;

  @override
  List<Object?> get props => [message, field, statusCode];
}

class AuthActionSuccess extends AuthState {
  const AuthActionSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
