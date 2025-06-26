import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:scifind/article_detail_page.dart';
import 'package:scifind/context/auth_service.dart';
import 'package:scifind/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../context/session_model.dart';

class RecommendedSection extends StatefulWidget {
  const RecommendedSection({super.key});

  @override
  State<RecommendedSection> createState() => _RecommendedSectionState();
}

class _RecommendedSectionState extends State<RecommendedSection> {
  List<dynamic> _articles = [];
  bool _loading = false;
  bool _clicked = false;
  bool _hasRecommendations = true;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final sesion = Provider.of<SesionModel>(context, listen: false);
    if (sesion.estaAutenticado) {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('recommendedArticles');
      if (saved != null) {
        final parsed = jsonDecode(saved);
        setState(() {
          _articles = parsed;
          _clicked = true;
          _hasRecommendations = _articles.isNotEmpty;
        });
      }
    }
  }

  Future<void> _fetchRecommendations() async {
    final sesion = Provider.of<SesionModel>(context, listen: false);
    final userId = sesion.usuario?['id'];
    if (userId == null) return;

    setState(() {
      _loading = true;
      _clicked = true;
    });

    try {
      final url = Uri.parse('${AuthService.baseUrl}api/UserData/recommendations/$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final articles = jsonDecode(response.body);
        setState(() {
          _articles = articles;
          _hasRecommendations = articles.isNotEmpty;
        });

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('recommendedArticles', jsonEncode(articles));
      } else {
        setState(() => _hasRecommendations = false);
      }
    } catch (e) {
      setState(() => _hasRecommendations = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _articleCard(dynamic article) {
    final title = article['title'] ?? 'Artículo sin título';
    final date = article['publishedDate'] ?? null;
    final displayDate = date != null ? DateTime.tryParse(date)?.toLocal().toString().split(' ')[0] : 'Fecha desconocida';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
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
            child: Text(title, style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
          ),
          SizedBox(height: 6),
          Text(displayDate ?? '', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = Provider.of<SesionModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artículos recomendados para ti',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple[200]),
          ),
          const SizedBox(height: 20),
          if (!sesion.estaAutenticado) ...[
            Text('Inicia sesión para recibir recomendaciones personalizadas.'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Provider.of<NavigationModel>(context, listen: false).updateIndex(2);
              },
              child: const Text('Iniciar sesión'),
            ),
          ] else if (!_clicked) ...[
            ElevatedButton.icon(
              onPressed: _fetchRecommendations,
              icon: Icon(Icons.recommend),
              label: Text('Obtener recomendaciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[800],
              ),
            ),
          ] else if (_loading) ...[
            const CircularProgressIndicator(),
          ] else if (!_hasRecommendations) ...[
            Text(
              'Aún no tenemos suficientes datos sobre tus intereses.\nExplora más artículos para obtener recomendaciones.',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Provider.of<NavigationModel>(context, listen: false).updateIndex(1),
              child: const Text('Explorar artículos'),
            ),
          ] else ...[
            ..._articles.map((article) => _articleCard(article)).toList(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchRecommendations,
              icon: const Icon(Icons.refresh),
              label: const Text('Obtener más recomendaciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[800],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
