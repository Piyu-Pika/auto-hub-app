import 'package:auto_hub_app/features/your_addresses/data/datasources/address_remote_datasource.dart';
import 'package:auto_hub_app/features/your_addresses/data/repositories/mock_address_repository.dart';
import 'package:auto_hub_app/features/your_addresses/domain/entities/address.dart';
import 'package:auto_hub_app/features/your_addresses/domain/repositories/address_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AddressRepository)
class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._remoteDatasource);

  final AddressRemoteDatasource _remoteDatasource;
  final MockAddressRepository _fallback = MockAddressRepository();

  @override
  Future<List<Address>> getAddresses() async {
    try {
      final list = await _remoteDatasource.getAddresses();
      if (list.isNotEmpty) return list;
      return await _fallback.getAddresses();
    } catch (_) {
      return _fallback.getAddresses();
    }
  }

  @override
  Future<void> addAddress(Address address) async {
    try {
      await _remoteDatasource.createAddress(address);
    } catch (_) {
      await _fallback.addAddress(address);
    }
  }

  @override
  Future<void> updateAddress(Address address) async {
    try {
      await _remoteDatasource.updateAddress(address);
    } catch (_) {
      await _fallback.updateAddress(address);
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await _remoteDatasource.deleteAddress(id);
    } catch (_) {
      await _fallback.deleteAddress(id);
    }
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    try {
      await _remoteDatasource.setDefaultAddress(id);
    } catch (_) {
      await _fallback.setDefaultAddress(id);
    }
  }
}

