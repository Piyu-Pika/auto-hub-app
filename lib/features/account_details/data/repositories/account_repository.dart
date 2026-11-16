import 'package:auto_hub_app/features/account_details/data/datasources/account_remote_datasource.dart';
import 'package:auto_hub_app/features/account_details/data/mock/mock_user_data.dart';
import 'package:auto_hub_app/features/account_details/domain/models/user_profile.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AccountRepository {
  @factoryMethod
  AccountRepository.withDatasource(this._datasource);

  factory AccountRepository() => getIt<AccountRepository>();
  static AccountRepository get instance => getIt<AccountRepository>();

  final AccountRemoteDatasource _datasource;

  UserProfile _currentUser = mockUserProfile;

  Future<UserProfile> getUserProfile() async {
    try {
      final remote = await _datasource.getUserProfile();
      _currentUser = remote;
      return _currentUser;
    } catch (_) {
      return _currentUser;
    }
  }

  Future<void> updateUserProfile(UserProfile updatedUser) async {
    try {
      final remote = await _datasource.updateUserProfile(
        fullName: updatedUser.fullName,
        phone: updatedUser.phone,
        location: updatedUser.location,
      );
      _currentUser = remote;
    } catch (_) {
      final nameParts = updatedUser.fullName.trim().split(' ');
      var newInitials = '';
      if (nameParts.isNotEmpty) {
        newInitials += nameParts.first.isNotEmpty
            ? nameParts.first[0].toUpperCase()
            : '';
        if (nameParts.length > 1) {
          newInitials += nameParts.last.isNotEmpty
              ? nameParts.last[0].toUpperCase()
              : '';
        }
      }

      _currentUser = updatedUser.copyWith(
        initials: newInitials.isEmpty ? '?' : newInitials,
      );
    }
  }
}
