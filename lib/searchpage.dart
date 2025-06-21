import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scifind/app_bar_header.dart';
import 'package:scifind/article_detail_page.dart';
import 'package:scifind/context/auth_service.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController topicController = TextEditingController();
  final TextEditingController authorController = TextEditingController();

  List<dynamic> _results = [];
  int _totalResults = 0;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoading = false;

  Future<void> _searchArticles({bool loadMore = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    if (!loadMore) {
      _currentPage = 1;
      _results.clear();
    }

    final query = topicController.text;
    final author = authorController.text;
    final url = Uri.parse("${AuthService.baseUrl}api/article/search")
        .replace(queryParameters: {
      "query": query,
      "author": author,
      "page": _currentPage.toString(),
      "pageSize": _pageSize.toString(),
    });

    try {
      final response = await http.get(url);
      print(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _results.addAll(data['results']);
          _totalResults = data['totalHits'];
          _currentPage++;
        });
      } else {
        print("Error en la búsqueda: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al hacer la solicitud: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHeader(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mostrando $_totalResults publicaciones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                isSmallScreen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildSearchFields(isSmallScreen),
                      )
                    : Row(
                        children: _buildSearchFields(isSmallScreen),
                      ),
                SizedBox(height: 40),
                Divider(color: Colors.grey[600]),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_results.isNotEmpty) ...[
                        Text(
                          "Resultados",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 10),
                        for (var article in _results) _buildArticleItem(article),
                        if (_results.isNotEmpty && _results.length < _totalResults) ...[
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _searchArticles(loadMore: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text('Cargar más'),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSearchFields(bool isSmallScreen) {
    final field1 = Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: topicController,
        decoration: InputDecoration(
          hintText: 'Buscar por tema o título',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(),
        ),
      ),
    );

    final field2 = Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: authorController,
        decoration: InputDecoration(
          hintText: 'Buscar por autor',
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(),
        ),
      ),
    );

    final button = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: _searchArticles,
        icon: Icon(Icons.search),
        label: Text('Buscar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
        ),
      ),
    );

    if (isSmallScreen) {
      return [field1, field2, button];
    } else {
      return [
        Expanded(child: field1),
        Expanded(child: field2),
        button,
      ];
    }
  }

  Widget _buildArticleItem(dynamic article) {
    final title = article['title'] ?? '';
    final abstract = article['abstract'] ?? '';
    final authors = (article['authors'] as List)
        .map((a) => a['name'])
        .toList()
        .join(', ');
    final publishedYear = article['yearPublished']?.toString() ?? 'Desconocido';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(articleId: article['id']),
                ),
              );
            },
            child: Text(
              title,
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          SizedBox(height: 4),
          Text(
            abstract,
            style: TextStyle(color: Colors.grey[300]),
          ),
          SizedBox(height: 4),
          Text(
            "Autores: $authors",
            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
          ),
          Text(
            "Publicado: $publishedYear",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
