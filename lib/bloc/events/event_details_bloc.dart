import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/events_details_model.dart';
import '../../server/repository.dart';

// Events
abstract class ZamooEventDetailsEvent {}

class GetZamooEventDetailsEvent extends ZamooEventDetailsEvent {
  final String eventId;
  final String userId;

  GetZamooEventDetailsEvent({required this.eventId, required this.userId});
}

// States
abstract class ZamooEventDetailsState {}

class ZamooEventDetailsInitialState extends ZamooEventDetailsState {}

class ZamooEventDetailsLoadingState extends ZamooEventDetailsState {}

class ZamooEventDetailsLoadedState extends ZamooEventDetailsState {
  final EventDetailsModel? eventDetailsModel;

  ZamooEventDetailsLoadedState({this.eventDetailsModel});
}

class ZamooEventDetailsErrorState extends ZamooEventDetailsState {
  final String error;

  ZamooEventDetailsErrorState({required this.error});
}

// Bloc
class ZamooEventDetailsBloc extends Bloc<ZamooEventDetailsEvent, ZamooEventDetailsState> {
  final Repository repository;

  ZamooEventDetailsBloc(this.repository) : super(ZamooEventDetailsInitialState());

  @override
  Stream<ZamooEventDetailsState> mapEventToState(ZamooEventDetailsEvent event) async* {
    if (event is GetZamooEventDetailsEvent) {
      yield* _mapGetZamooEventDetailsToState(event.eventId, event.userId);
    }
  }

  Stream<ZamooEventDetailsState> _mapGetZamooEventDetailsToState(String eventId, String userId) async* {
    yield ZamooEventDetailsLoadingState(); // Loading state

    try {
      final eventDetails = await repository.getEventDetails(eventId: eventId, userId: userId);

      if (eventDetails != null) {
        yield ZamooEventDetailsLoadedState(eventDetailsModel: eventDetails); // Loaded state
      } else {
        yield ZamooEventDetailsErrorState(error: 'Event details not found.');
      }
    } catch (e) {
      yield ZamooEventDetailsErrorState(error: 'Error fetching event details: ${e.toString()}'); // Error state
    }
  }
}
