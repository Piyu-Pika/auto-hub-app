// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_hub_app/core/network/api_client.dart' as _i677;
import 'package:auto_hub_app/core/network/token_storage.dart' as _i991;
import 'package:auto_hub_app/features/account_details/data/datasources/account_remote_datasource.dart'
    as _i1067;
import 'package:auto_hub_app/features/account_details/data/repositories/account_repository.dart'
    as _i195;
import 'package:auto_hub_app/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i518;
import 'package:auto_hub_app/features/auth/data/repositories/auth_repository_impl.dart'
    as _i928;
import 'package:auto_hub_app/features/auth/domain/repositories/auth_repository.dart'
    as _i22;
import 'package:auto_hub_app/features/auth/presentation/bloc/auth_bloc.dart'
    as _i301;
import 'package:auto_hub_app/features/browse/data/datasources/browse_remote_datasource.dart'
    as _i179;
import 'package:auto_hub_app/features/browse/data/repositories/browse_repository_impl.dart'
    as _i73;
import 'package:auto_hub_app/features/browse/domain/repositories/browse_repository.dart'
    as _i252;
import 'package:auto_hub_app/features/cart/data/datasources/cart_remote_datasource.dart'
    as _i273;
import 'package:auto_hub_app/features/cart/data/repositories/cart_repository_impl.dart'
    as _i70;
import 'package:auto_hub_app/features/cart/domain/repositories/cart_repository.dart'
    as _i996;
import 'package:auto_hub_app/features/contact_support/data/datasources/chat_remote_datasource.dart'
    as _i1052;
import 'package:auto_hub_app/features/contact_support/data/repositories/chat_repository_impl.dart'
    as _i292;
import 'package:auto_hub_app/features/contact_support/domain/repositories/chat_repository.dart'
    as _i817;
import 'package:auto_hub_app/features/help_center/data/datasources/help_remote_datasource.dart'
    as _i108;
import 'package:auto_hub_app/features/help_center/data/repositories/help_repository_impl.dart'
    as _i925;
import 'package:auto_hub_app/features/help_center/domain/repositories/help_repository.dart'
    as _i567;
import 'package:auto_hub_app/features/home/data/datasources/home_remote_datasource.dart'
    as _i909;
import 'package:auto_hub_app/features/home/data/repositories/home_repository_impl.dart'
    as _i781;
import 'package:auto_hub_app/features/home/domain/repositories/home_repository.dart'
    as _i147;
import 'package:auto_hub_app/features/home/presentation/bloc/home_cubit.dart'
    as _i371;
import 'package:auto_hub_app/features/my_order/data/datasources/order_remote_datasource.dart'
    as _i319;
import 'package:auto_hub_app/features/my_order/data/orders_repository.dart'
    as _i35;
import 'package:auto_hub_app/features/payment_methods/data/datasources/payment_remote_datasource.dart'
    as _i275;
import 'package:auto_hub_app/features/payment_methods/data/repositories/payment_methods_repository_impl.dart'
    as _i399;
import 'package:auto_hub_app/features/payment_methods/domain/repositories/payment_methods_repository.dart'
    as _i61;
import 'package:auto_hub_app/features/request_junk/data/datasources/junk_remote_datasource.dart'
    as _i518;
import 'package:auto_hub_app/features/request_junk/data/repositories/junk_repository_impl.dart'
    as _i503;
import 'package:auto_hub_app/features/request_junk/domain/repositories/junk_repository.dart'
    as _i444;
import 'package:auto_hub_app/features/request_junk/presentation/cubit/junk_cubit.dart'
    as _i214;
import 'package:auto_hub_app/features/settings/data/datasources/settings_remote_datasource.dart'
    as _i734;
import 'package:auto_hub_app/features/settings/data/repositories/settings_repository.dart'
    as _i401;
import 'package:auto_hub_app/features/splash/presentation/bloc/splash_cubit.dart'
    as _i1035;
import 'package:auto_hub_app/features/vin/data/datasources/vin_remote_datasource.dart'
    as _i108;
import 'package:auto_hub_app/features/vin/data/repositories/vin_repository_impl.dart'
    as _i795;
import 'package:auto_hub_app/features/vin/domain/repositories/vin_repository.dart'
    as _i683;
import 'package:auto_hub_app/features/vin/domain/usecases/decode_vin_usecase.dart'
    as _i961;
import 'package:auto_hub_app/features/vin/presentation/cubit/vin_cubit.dart'
    as _i467;
import 'package:auto_hub_app/features/your_addresses/data/datasources/address_remote_datasource.dart'
    as _i818;
import 'package:auto_hub_app/features/your_addresses/data/repositories/address_repository_impl.dart'
    as _i484;
import 'package:auto_hub_app/features/your_addresses/domain/repositories/address_repository.dart'
    as _i878;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    gh.factory<_i1035.SplashCubit>(
      () => _i1035.SplashCubit(
        gh<_i22.AuthRepository>(),
        gh<_i991.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i991.TokenStorage>(() => _i991.InMemoryTokenStorage());
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(gh<_i991.TokenStorage>()),
    );
    gh.lazySingleton<_i319.OrderRemoteDatasource>(
      () => _i319.OrderRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i273.CartRemoteDatasource>(
      () => _i273.CartRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i909.HomeRemoteDatasource>(
      () => _i909.HomeRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1052.ChatRemoteDatasource>(
      () => _i1052.ChatRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i818.AddressRemoteDatasource>(
      () => _i818.AddressRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i108.HelpRemoteDatasource>(
      () => _i108.HelpRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1067.AccountRemoteDatasource>(
      () => _i1067.AccountRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i35.OrdersRepository>(
      () => _i35.OrdersRepository(gh<_i319.OrderRemoteDatasource>()),
    );
    gh.lazySingleton<_i817.ChatRepository>(
      () => _i292.ChatRepositoryImpl(gh<_i1052.ChatRemoteDatasource>()),
    );
    gh.lazySingleton<_i996.CartRepository>(
      () => _i70.CartRepositoryImpl(gh<_i273.CartRemoteDatasource>()),
    );
    gh.lazySingleton<_i734.SettingsRemoteDatasource>(
      () => _i734.SettingsRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i108.VinRemoteDatasource>(
      () => _i108.VinRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i179.BrowseRemoteDatasource>(
      () => _i179.BrowseRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i878.AddressRepository>(
      () => _i484.AddressRepositoryImpl(gh<_i818.AddressRemoteDatasource>()),
    );
    gh.lazySingleton<_i518.JunkRemoteDatasource>(
      () => _i518.JunkRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i518.AuthRemoteDatasource>(
      () => _i518.AuthRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i567.HelpRepository>(
      () => _i925.HelpRepositoryImpl(gh<_i108.HelpRemoteDatasource>()),
    );
    gh.lazySingleton<_i275.PaymentRemoteDatasource>(
      () => _i275.PaymentRemoteDatasourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i252.BrowseRepository>(
      () => _i73.BrowseRepositoryImpl(gh<_i179.BrowseRemoteDatasource>()),
    );
    gh.lazySingleton<_i195.AccountRepository>(
      () => _i195.AccountRepository.withDatasource(
        gh<_i1067.AccountRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i147.HomeRepository>(
      () => _i781.HomeRepositoryImpl(gh<_i909.HomeRemoteDatasource>()),
    );
    gh.lazySingleton<_i22.AuthRepository>(
      () => _i928.AuthRepositoryImpl(
        remoteDatasource: gh<_i518.AuthRemoteDatasource>(),
        tokenStorage: gh<_i991.TokenStorage>(),
      ),
    );
    gh.factory<_i301.AuthBloc>(() => _i301.AuthBloc(gh<_i22.AuthRepository>()));
    gh.lazySingleton<_i401.SettingsRepository>(
      () => _i401.SettingsRepository.withDatasource(
        gh<_i734.SettingsRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i61.PaymentMethodsRepository>(
      () => _i399.PaymentMethodsRepositoryImpl(
        gh<_i275.PaymentRemoteDatasource>(),
      ),
    );
    gh.lazySingleton<_i683.VinRepository>(
      () => _i795.VinRepositoryImpl(gh<_i108.VinRemoteDatasource>()),
    );
    gh.lazySingleton<_i444.JunkRepository>(
      () => _i503.JunkRepositoryImpl(gh<_i518.JunkRemoteDatasource>()),
    );
    gh.factory<_i371.HomeCubit>(
      () => _i371.HomeCubit(gh<_i147.HomeRepository>()),
    );
    gh.factory<_i214.JunkCubit>(
      () => _i214.JunkCubit(gh<_i444.JunkRepository>()),
    );
    gh.lazySingleton<_i961.DecodeVinUsecase>(
      () => _i961.DecodeVinUsecase(gh<_i683.VinRepository>()),
    );
    gh.factory<_i467.VinCubit>(
      () => _i467.VinCubit(gh<_i961.DecodeVinUsecase>()),
    );
    return this;
  }
}

class _$NetworkModule extends _i677.NetworkModule {}
