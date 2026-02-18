import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/events_model.dart';
import '../../server/repository.dart';

// Events
abstract class ZamooEventsEvent {}

class GetZamooEventsEvent extends ZamooEventsEvent {
  final dynamic param;
  GetZamooEventsEvent({this.param});
}

// States
abstract class ZamooEventsState {}

class ZamooEventsInitialState extends ZamooEventsState {}

class ZamooEventsLoadingState extends ZamooEventsState {}

class ZamooEventsLoadedState extends ZamooEventsState {
  final List<EventsModel>? listEvents;
  ZamooEventsLoadedState({this.listEvents});
}

class ZamooEventsErrorState extends ZamooEventsState {
  final String error;
  ZamooEventsErrorState({required this.error});
}

// Bloc
class ZamooEventsBloc extends Bloc<ZamooEventsEvent, ZamooEventsState> {
  final Repository repository;

  ZamooEventsBloc(this.repository) : super(ZamooEventsInitialState());

  @override
  Stream<ZamooEventsState> mapEventToState(ZamooEventsEvent event) async* {
    if (event is GetZamooEventsEvent) {
      yield* _mapGetZamooEventsToState();
    }
  }

  Stream<ZamooEventsState> _mapGetZamooEventsToState() async* {
    yield ZamooEventsLoadingState(); // Loading state
    try {
      // Fetch events from the repository
      final listEvents = await repository.getEventsList();
      if (listEvents != null && listEvents.isNotEmpty) {
        yield ZamooEventsLoadedState(listEvents: listEvents); // Success state
      } else {
        yield ZamooEventsErrorState(error: 'No events found.');
      }
    } catch (e) {
      yield ZamooEventsErrorState(error: 'Error fetching events: ${e.toString()}'); // Error state
    }
  }
}
