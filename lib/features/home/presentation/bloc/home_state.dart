import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.feed);

  final HomeFeedEntity feed;

  @override
  List<Object?> get props => [feed];
}

class HomeEmpty extends HomeState {
  const HomeEmpty();
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
