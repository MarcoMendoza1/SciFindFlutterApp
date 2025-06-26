import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scifind/context/auth_service.dart';
import 'package:scifind/utils/crypto.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;

  const ArticleDetailScreen({required this.articleId, super.key});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  Map<String, dynamic>? article;
  bool isLoading = true;
  bool isFavorite = false;
  Map<String, dynamic>? userArticle;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    user = await AuthService.getUser();
    await fetchArticleDetail();

    if (user != null && article != null) {
      await saveVisitToHistory();
      await checkIfFavorite();
    }
  }

  Future<void> fetchArticleDetail() async {
    final url = Uri.parse("${AuthService.baseUrl}api/article/${widget.articleId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          article = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener artículo');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveVisitToHistory() async {
    final encryptedId = CryptoHelper.encryptArticleId(article!['id'].toString(), article!['title']);
    final url = Uri.parse("${AuthService.baseUrl}api/UserData/history");

    final body = jsonEncode({
      "userId": user!['id'],
      "articleId": encryptedId,
      "isFavorite": false,
    });

    try {
      await http.post(url, headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      print("❌ Error al guardar historial: $e");
    }
  }

  Future<void> checkIfFavorite() async {
    /* final encryptedId = CryptoHelper.encryptArticleId(article!['id'].toString(), article!['title']);
    final safeId = Uri.encodeComponent(encryptedId);
    final url = Uri.parse("${AuthService.baseUrl}api/UserData/favorites/${user!['id']}/check/$safeId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          isFavorite = response.body == 'true';
        });
      }
    } catch (e) {
      print("❌ Error al verificar favorito: $e");
    } */

    final encryptedId = CryptoHelper.encryptArticleId(article!['id'].toString(), article!['title']);

    final historyRes = await http.get(
      Uri.parse("${AuthService.baseUrl}api/UserData/history/${user!['id']}"),
    );

    final history = jsonDecode(historyRes.body);
    final existing = history.firstWhere(
      (item) => item['articleId'] == encryptedId,
      orElse: () => null,
    );

    userArticle = existing;

   if(userArticle!["isFavorite"]){
    setState(() {
      isFavorite = true;
      isLoading = false;
    });
   }else{
    setState(() {
      isFavorite = false;
      isLoading = false;
    });
   }
  }

  Future<void> toggleFavorite() async {
    final encryptedId = CryptoHelper.encryptArticleId(article!['id'].toString(), article!['title']);
    final safeId = Uri.encodeComponent(encryptedId);

    try {

      var newFav = {...userArticle!, "isFavorite": !isFavorite};
      print(userArticle);
      print(newFav);
      final response = await http.put(
        Uri.parse("${AuthService.baseUrl}api/UserData/history/${userArticle!['id']}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newFav),
      );

      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      print("❌ Error al actualizar favorito: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles del Artículo"),
        actions: [
          if (user != null && article != null)
            IconButton(
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
              onPressed: toggleFavorite,
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : article == null
              ? Center(child: Text("No se pudo cargar el artículo"))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article!['title'] ?? 'Sin título',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[200]),
                      ),
                      SizedBox(height: 10),
                      Text("Publicado: ${_formatDate(article!['publishedDate'])}", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Autores: ${_authorsList(article!['authors'])}"),
                      Text("Temas: ${article!['subjects'].join(', ')}"),
                      SizedBox(height: 20),
                      _section("Resumen", article!['abstract']),
                      SizedBox(height: 20),
                      _section("Texto completo", article!['fullText']),
                      SizedBox(height: 20),
                      _linksSection(article!['links']),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return "Desconocido";
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return "${date.day}/${date.month}/${date.year}";
  }

  String _authorsList(List<dynamic> authors) {
    return authors.map((a) => a['name']).join(', ');
  }

  Widget _section(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[300], fontSize: 18)),
        SizedBox(height: 5),
        Text(content ?? "No disponible", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _linksSection(List<dynamic> links) {
    if (links.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Enlaces", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[300], fontSize: 18)),
        SizedBox(height: 8),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: GestureDetector(
                onTap: () {
                  // puedes usar url_launcher aquí
                },
                child: Text(
                  _linkLabel(link),
                  style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
                ),
              ),
            )),
      ],
    );
  }

  String _linkLabel(Map<String, dynamic> link) {
    switch (link['type']) {
      case 'download':
        return 'Descargar PDF';
      case 'display':
        return 'Fuente adicional 1';
      default:
        return 'Fuente adicional';
    }
  }
}
