import 'package:auto_hub_app/features/request_junk/domain/repositories/junk_repository.dart';
import 'package:auto_hub_app/features/request_junk/models/junk_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

abstract class JunkState extends Equatable {
  const JunkState();

  @override
  List<Object?> get props => [];
}

class JunkInitial extends JunkState {
  const JunkInitial();
}

class JunkLoading extends JunkState {
  const JunkLoading();
}

class JunkLoaded extends JunkState {
  const JunkLoaded(this.requests);

  final List<JunkRequest> requests;

  @override
  List<Object?> get props => [requests];
}

class JunkQuoteLoaded extends JunkState {
  const JunkQuoteLoaded(this.quote);

  final Map<String, dynamic> quote;

  @override
  List<Object?> get props => [quote];
}

class JunkRequestCreated extends JunkState {
  const JunkRequestCreated(this.request);

  final JunkRequest request;

  @override
  List<Object?> get props => [request];
}

class JunkOfferAccepted extends JunkState {
  const JunkOfferAccepted(this.request);

  final JunkRequest request;

  @override
  List<Object?> get props => [request];
}

class JunkEmpty extends JunkState {
  const JunkEmpty();
}

class JunkError extends JunkState {
  const JunkError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

@injectable
class JunkCubit extends Cubit<JunkState> {
  JunkCubit(this._junkRepository) : super(const JunkInitial());

  final JunkRepository _junkRepository;

  Future<void> loadRequests({String status = 'all'}) async {
    emit(const JunkLoading());
    final result = await _junkRepository.getJunkRequests(status: status);

    result.fold(
      (failure) => emit(JunkError(failure.message)),
      (requests) {
        if (requests.isEmpty) {
          emit(const JunkEmpty());
        } else {
          emit(JunkLoaded(requests));
        }
      },
    );
  }

  Future<void> fetchQuote({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    String? vin,
  }) async {
    emit(const JunkLoading());
    final result = await _junkRepository.getInstantQuote(
      year: year,
      make: make,
      model: model,
      condition: condition,
      hasTitle: hasTitle,
      hasKeys: hasKeys,
      vin: vin,
    );

    result.fold(
      (failure) => emit(JunkError(failure.message)),
      (quote) => emit(JunkQuoteLoaded(quote)),
    );
  }

  Future<bool> createRequest({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    required String pickupAddress,
    String? vin,
    String? notes,
    List<String>? imageUrls,
  }) async {
    emit(const JunkLoading());
    final result = await _junkRepository.createJunkRequest(
      year: year,
      make: make,
      model: model,
      condition: condition,
      hasTitle: hasTitle,
      hasKeys: hasKeys,
      pickupAddress: pickupAddress,
      vin: vin,
      notes: notes,
      imageUrls: imageUrls,
    );

    return result.fold(
      (failure) {
        emit(JunkError(failure.message));
        return false;
      },
      (request) {
        emit(JunkRequestCreated(request));
        return true;
      },
    );
  }

  Future<bool> acceptOffer(String id, {required int offerAmount}) async {
    emit(const JunkLoading());
    final result = await _junkRepository.acceptOffer(id, offerAmount: offerAmount);

    return result.fold(
      (failure) {
        emit(JunkError(failure.message));
        return false;
      },
      (request) {
        emit(JunkOfferAccepted(request));
        return true;
      },
    );
  }
}
