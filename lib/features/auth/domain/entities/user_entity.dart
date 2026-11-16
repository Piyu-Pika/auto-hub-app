import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.location,
    this.avatarUrl,
    this.memberSince,
    this.accountType,
    this.initials,
    this.isVerified = false,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? location;
  final String? avatarUrl;
  final String? memberSince;
  final String? accountType;
  final String? initials;
  final bool isVerified;

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        location,
        avatarUrl,
        memberSince,
        accountType,
        initials,
        isVerified,
      ];
}
