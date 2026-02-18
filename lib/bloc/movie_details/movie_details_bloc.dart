import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:oxoo/models/movie_details_model.dart';
import 'package:oxoo/server/repository.dart';

part 'movie_details_event.dart';
part 'movie_details_state.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final Repository repository;

  MovieDetailsBloc({required this.repository}) : super(MovieDetailsInitialState()) {
    // Register the event handler
    on<GetMovieDetailsEvent>(_onGetMovieDetailsEvent);
  }

  // Event handler
  Future<void> _onGetMovieDetailsEvent(
      GetMovieDetailsEvent event,
      Emitter<MovieDetailsState> emit,
      ) async {
    emit(MovieDetailsInitialState());
    try {
      final MovieDetailsModel detailsModel = await repository.getMovieDetailsData(
        movieId: event.movieID,
        userId: event.userID,
      );
      emit(MovieDetailsLoadedState(movieDetails: detailsModel));
    } catch (e) {
      emit(MovieDetailsErrorState(message: e.toString()));
    }
  }
}

