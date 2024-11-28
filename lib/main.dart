import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StarWarsApp());
}

class StarWarsApp extends StatelessWidget {
  const StarWarsApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Wars Movies',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MovieTabs(),
    );
  }
}

class MovieTabs extends StatefulWidget {
  const MovieTabs({super.key});

  @override
  _MovieTabsState createState() => _MovieTabsState();
}

class _MovieTabsState extends State<MovieTabs> {
  final List<Map<String, String>> _favoriteMovies = [];

  void _addToFavorites(Map<String, String> movie) {
    if (!_favoriteMovies.any((favMovie) => favMovie['title'] == movie['title'])) {
      setState(() {
        _favoriteMovies.add(movie);
      });
    } else {
      setState(() {
        _favoriteMovies.removeWhere((favMovie) => favMovie['title'] == movie['title']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Star Wars Movies'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Movies'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MovieList(
              onFavorite: _addToFavorites,
              favoriteMovies: _favoriteMovies,
            ),
            FavoriteMovies(movies: _favoriteMovies),
          ],
        ),
      ),
    );
  }
}

class MovieList extends StatefulWidget {
  final Function(Map<String, String>) onFavorite;
  final List<Map<String, String>> favoriteMovies;

  const MovieList({super.key, required this.onFavorite, required this.favoriteMovies});

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<Map<String, String>> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse('https://swapi.dev/api/films/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _movies = List<Map<String, String>>.from(data['results'].map((movie) => {
              'title': movie['title']?.toString() ?? '',
              'director': movie['director']?.toString() ?? '',
              'release_date': movie['release_date']?.toString() ?? '',
            }));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              final movie = _movies[index];
              final isFavorite = widget.favoriteMovies.any((favMovie) =>
                  favMovie['title'] == movie['title']);
              return ListTile(
                title: Text(movie['title'] ?? ''),
                subtitle: Text('Directed by ${movie['director']}'),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    widget.onFavorite(movie);
                  },
                ),
              );
            },
          );
  }
}


class FavoriteMovies extends StatelessWidget {
  final List<Map<String, String>> movies;

  const FavoriteMovies({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return movies.isEmpty
        ? const Center(child: Text('Not favorite movies yet!'))
        : ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                title: Text(movie['title'] ?? ''),
                subtitle: Text('Directed by ${movie['director']}'),
              );
            },
          );
  }
}
