import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/live_tv_details_model.dart';
import '../../server/repository.dart';

class LiveTvDetailsEvent {}

class GetLiveTvDetailsEvent extends LiveTvDetailsEvent {
  final String liveTvId;
  final String userId;
  GetLiveTvDetailsEvent({required this.liveTvId, required this.userId});
}

class LiveTvDetailsState {}

class LiveTvDetailsInitialState extends LiveTvDetailsState {}

class LiveTvDetailsIsLoading extends LiveTvDetailsState {}

class LiveTvDetailsIsLoaded extends LiveTvDetailsState {
  final LiveTvDetailsModel liveTvDetailsModel;
  LiveTvDetailsIsLoaded({required this.liveTvDetailsModel});
}

class LiveTvDetailsErrorState extends LiveTvDetailsState {
  final String error;
  LiveTvDetailsErrorState({required this.error});
}

class LiveTvDetailsBloc extends Bloc<LiveTvDetailsEvent, LiveTvDetailsState> {
  final Repository repository;

  LiveTvDetailsBloc(this.repository) : super(LiveTvDetailsInitialState()) {
    // Registering the event handler
    on<GetLiveTvDetailsEvent>(_onGetLiveTvDetailsEvent);
  }

  Future<void> _onGetLiveTvDetailsEvent(
      GetLiveTvDetailsEvent event,
      Emitter<LiveTvDetailsState> emit,
      ) async {
    emit(LiveTvDetailsIsLoading());
    try {
      final liveTvDetailsModel = await repository.getLiveTVDetailsData(
        liveTvId: event.liveTvId,
        userId: event.userId,
      );
      emit(LiveTvDetailsIsLoaded(liveTvDetailsModel: liveTvDetailsModel!));
    } catch (e) {
      emit(LiveTvDetailsErrorState(error: e.toString()));
    }
  }
}
