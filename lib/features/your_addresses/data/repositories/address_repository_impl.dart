import 'package:auto_hub_app/features/your_addresses/data/datasources/address_remote_datasource.dart';
import 'package:auto_hub_app/features/your_addresses/domain/entities/address.dart';
import 'package:auto_hub_app/features/your_addresses/domain/repositories/address_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AddressRepository)
class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._remoteDatasource);

  final AddressRemoteDatasource _remoteDatasource;

  @override
  Future<List<Address>> getAddresses() async {
    return _remoteDatasource.getAddresses();
  }

  @override
  Future<void> addAddress(Address address) async {
    await _remoteDatasource.createAddress(address);
  }

  @override
  Future<void> updateAddress(Address address) async {
    await _remoteDatasource.updateAddress(address);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _remoteDatasource.deleteAddress(id);
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    await _remoteDatasource.setDefaultAddress(id);
  }
}
