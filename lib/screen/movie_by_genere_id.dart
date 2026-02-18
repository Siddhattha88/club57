import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:oxoo/screen/tv_series/tv_series_details_screen.dart';
import '../../strings.dart';
import 'package:hive/hive.dart';
import '../../models/movie_model.dart';
import '../../screen/movie/movie_details_screen.dart';
import '../../server/repository.dart';
import '../../style/theme.dart';
import '../../utils/loadingIndicator.dart';
import '../constants.dart';

class MoviesScreenByGenereID extends StatefulWidget {
  static final String route = '/MoviesScreenByGenereID';

  @override
  _MoviesScreenByGenereIDState createState() => _MoviesScreenByGenereIDState();
}

class _MoviesScreenByGenereIDState extends State<MoviesScreenByGenereID> {
  late String genereID; // To store the genereID
  static const int PAGE_SIZE = 20;
  late ScrollController _scrollController;
  late bool isDark;
  final appModeBox = Hive.box('appModeBox');
  List<MovieModel> movies = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  bool isInitialized = false; // Flag to prevent repeated initialization

  @override
  void initState() {
    super.initState();
    // // Retrieve the arguments passed from the previous screen
    // final arguments =
    // ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // genereID = arguments['genereID']; // Extract genereID
    isDark = appModeBox.get('isDark') ?? false;
    _scrollController = ScrollController()..addListener(_onScroll);
    // _fetchMovies(genereID);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Perform initialization only once
    if (!isInitialized) {
      final arguments =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      genereID = arguments['genereID']; // Extract genereID
      isInitialized = true; // Mark initialization as complete
      _fetchMovies(genereID);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMovies(String genreId) async {
    if (isLoading || !hasMoreData) return;

    setState(() {
      isLoading = true;
    });

    try {
      log("Fetching page $currentPage");
      final List<MovieModel>? newMovies =
      await Repository().getMovieByGenereID(currentPage.toString(), genreId);

      if (newMovies == null || newMovies.isEmpty) {
        hasMoreData = false;
      } else {
        setState(() {
          movies.addAll(newMovies);
          currentPage++;
        });
      }
    } catch (e) {
      log("Error fetching movies: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300 &&
        !isLoading &&
        hasMoreData) {
      _fetchMovies(genereID);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: _buildAppBar(routes['isPresentAppBar'], routes['title']),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      color: isDark ? CustomTheme.primaryColorDark : Colors.white,
      child: movies.isEmpty
          ? Center(
        child: isLoading
            ? spinkit // Show the loading indicator in the center if loading
            : _noItemFound(), // Show "No items found" when not loading
      )
          : Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 0.0,
                childAspectRatio: 0.58,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return _itemBuilder(context, movies[index]);
              },
            ),
          ),
          if (isLoading) spinkit, // Show the loading indicator during pagination
        ],
      ),
    );
  }

  AppBar? _buildAppBar(bool isPresentAppBar, String title) {
    if (isPresentAppBar) {
      return AppBar(
        iconTheme: IconThemeData(
          color: isDark ? CustomTheme.primaryColorRed : CustomTheme.primaryColorDark,
        ),
        titleTextStyle: TextStyle(
          fontSize: 24,
          color: isDark ? CustomTheme.primaryColorRed : CustomTheme.primaryColorDark,
        ),
        backgroundColor:
        isDark ? CustomTheme.primaryColorDark : CustomTheme.primaryColor,
        title: Text(title),
      );
    }
    return null;
  }

  Widget _noItemFound() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 150),
        child: Text(
          "No items found",
          style: isDark ? CustomTheme.bodyText2White : CustomTheme.bodyText2,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, MovieModel model) {
    return InkWell(
      onTap: () {
        switch (model.isTvseries) {
          case "1":
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TvSerisDetailsScreen(
                      seriesID: model.videosId,
                      isPaid: '',
                    )),
              );
            }
            break;
          case "0":
            {
              Navigator.pushNamed(context, MovieDetailScreen.route, arguments: {"movieID": model.videosId});
            }
            break;

          default:
            {
              //statements;
              print("tv ot others");
            }
            break;
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Card(
          color: isDark ? CustomTheme.primaryColorDark : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                ),
                child: Image.network(
                  model.thumbnailUrl!,
                  fit: BoxFit.fill,
                  height: 160,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.fill,
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 2),
                padding: EdgeInsets.only(left: 2, right: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.title!,
                      overflow: TextOverflow.ellipsis,
                      style: isDark
                          ? CustomTheme.smallTextWhite.copyWith(fontSize: 13)
                          : CustomTheme.smallText.copyWith(fontSize: 13),
                    ),
                    Row(
                      children: [
                        Text(model.videoQuality!,
                            textAlign: TextAlign.start,
                            style: isDark
                                ? CustomTheme.smallTextWhite
                                : CustomTheme.smallText),
                        Expanded(
                          child: Text(model.release!,
                              textAlign: TextAlign.end,
                              style: isDark
                                  ? CustomTheme.smallTextWhite
                                  : CustomTheme.smallText),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
