import 'package:auto_hub_app/features/home/domain/repositories/home_repository.dart';
import 'package:auto_hub_app/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepository) : super(const HomeInitial());

  final HomeRepository _homeRepository;

  Future<void> loadFeed({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(const HomeLoading());
    }

    final result = await _homeRepository.getHomeFeed();

    result.fold(
      (failure) {
        if (!isRefresh) {
          emit(HomeError(failure.message));
        }
      },
      (feed) {
        if (feed.featured.isEmpty && feed.recent.isEmpty && feed.categories.isEmpty) {
          emit(const HomeEmpty());
        } else {
          emit(HomeLoaded(feed));
        }
      },
    );
  }
}
