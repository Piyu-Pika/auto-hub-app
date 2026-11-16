import 'package:auto_hub_app/features/account_details/data/datasources/account_remote_datasource.dart';
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

  UserProfile? _currentUser;

  Future<UserProfile> getUserProfile() async {
    final remote = await _datasource.getUserProfile();
    _currentUser = remote;
    return remote;
  }

  Future<void> updateUserProfile(UserProfile updatedUser) async {
    final remote = await _datasource.updateUserProfile(
      fullName: updatedUser.fullName,
      phone: updatedUser.phone,
      location: updatedUser.location,
    );
    _currentUser = remote;
  }
}
