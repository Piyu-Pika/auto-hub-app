import 'package:auto_hub_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    super.location,
    super.avatarUrl,
    super.memberSince,
    super.accountType,
    super.initials,
    super.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      memberSince: json['memberSince'] as String?,
      accountType: json['accountType'] as String?,
      initials: json['initials'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (location != null) 'location': location,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (memberSince != null) 'memberSince': memberSince,
      if (accountType != null) 'accountType': accountType,
      if (initials != null) 'initials': initials,
      'isVerified': isVerified,
    };
  }
}
