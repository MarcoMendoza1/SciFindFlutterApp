import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scifind/article_detail_page.dart';
import 'dart:convert';

import 'package:scifind/context/auth_service.dart';
import 'package:scifind/utils/crypto.dart';

class UserHistoryScreen extends StatefulWidget {
  final int userId;
  const UserHistoryScreen({super.key, required this.userId});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  List<dynamic> history = [];
  bool loading = true;
  String message = "";

  Future<void> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('${AuthService.baseUrl}api/UserData/history/${widget.userId}'));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        // Simulamos el descifrado de articleId
        history = data.map((item) {
          final decrypted = CryptoHelper.decryptArticleId(item['articleId']);
          final parts = decrypted.split('-');
          return {
            'id': item['id'],
            'articleTitle': parts.sublist(1).join('-'),
            'originalId': parts[0],
            'isFavorite': item['isFavorite'] ?? false,
          };
        }).toList();
      } else {
        message = "No se pudo cargar el historial.";
      }
    } catch (e) {
      message = "Error de red: $e";
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      final response = await http.delete(Uri.parse('${AuthService.baseUrl}api/UserData/history/$id'));
      if (response.statusCode == 200) {
        setState(() {
          message = "Actividad eliminada correctamente.";
        });
        fetchHistory();
      } else {
        setState(() {
          message = "No se pudo eliminar la actividad.";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error: $e";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Usuario (ID: ${widget.userId})'),
        backgroundColor: Colors.purple[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? Center(child: CircularProgressIndicator())
            : history.isEmpty
                ? Center(child: Text("No hay historial."))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: message.contains("eliminada")
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  item['articleTitle'],
                                  style: TextStyle(color: Colors.blue),
                                ),
                                subtitle: Text('ID: ${item['id']} | Favorito: ${item['isFavorite'] ? "⭐ Sí" : "No"}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteActivity(item['id']),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ArticleDetailScreen(articleId: item['originalId'])),
                                  );
                                  
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
