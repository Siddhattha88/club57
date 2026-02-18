import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oxoo/models/content_by_country_model.dart';
import 'package:oxoo/server/repository.dart';

part 'country_movie_event.dart';
part 'country_movie_state.dart';

class CountryMovieBloc extends Bloc<CountryMovieEvent, CountryMovieState> {
  final Repository repository;

  CountryMovieBloc({required this.repository}) : super(CountryMovieLoadingState()) {
    // Registering the event handler
    on<GetMovieByCountryEvent>(_onGetMovieByCountryEvent);
  }

  Future<void> _onGetMovieByCountryEvent(
      GetMovieByCountryEvent event,
      Emitter<CountryMovieState> emit,
      ) async {
    emit(CountryMovieLoadingState());
    try {
      final contentByCountryModel = await repository.contentByCountry(
        countryID: event.countryId,
      );
      emit(CountryMovieLoadedState(countryModel: contentByCountryModel));
    } catch (e) {
      emit(CountryMovieErrorState(message: "Country Data error: ${e.toString()}"));
    }
  }
}
