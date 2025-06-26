import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scifind/app_bar_header.dart';
import 'package:scifind/context/auth_service.dart';
import 'package:scifind/context/session_model.dart';
import 'package:scifind/login_register_page.dart';
import 'package:scifind/recomended_section.dart';
import 'package:scifind/searchpage.dart';
import 'package:scifind/userprofilepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.loadBaseUrl();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SesionModel()..verificarSesion()),
        ChangeNotifierProvider(create: (_) => NavigationModel()),
      ],
      child: MaterialApp(
        title: 'SciFind',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.purple[800],
          scaffoldBackgroundColor: Colors.black,
        ),
        home: Scaffold(
          appBar: AppBarHeader(),
          body: SciFindApp()
        ),
      ),
    ),
  );
}

class NavigationModel with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class SciFindApp extends StatelessWidget {
  const SciFindApp({super.key});

  List<Widget> _buildPages(BuildContext context) {
    final sesion = Provider.of<SesionModel>(context);
    return [
      SearchScreen(),
      SearchResultsScreen(),
      sesion.estaAutenticado
          ? UserProfileScreen()
          : RegisterLoginScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navModel = Provider.of<NavigationModel>(context);
    
    return Scaffold(
      body: _buildPages(context)[navModel.currentIndex],
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: navModel.currentIndex,
        onDestinationSelected: (index) {
          navModel.updateIndex(index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.article),
            label: 'Artículos',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Artículos',
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController authorController = TextEditingController();

  SearchScreen({super.key});

  Widget _topicLink(String text) {
    return GestureDetector(
      onTap: () {
      },
      child: Text(
        text,
        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      ),
    );
  }

  Widget _articleItem(String title, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.blue),
          ),
          Text(
            details,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buscar artículos científicos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink[200]),
              ),
              SizedBox(height: 20),
              Text('Término de búsqueda'),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Ej: inteligencia artificial',
                ),
              ),
              SizedBox(height: 16),
              Text('Autor(es)'),
              TextField(
                controller: authorController,
                decoration: InputDecoration(
                  hintText: 'Ej: Juan Pérez',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Aquí iría la lógica de búsqueda
                },
                icon: Icon(Icons.search),
                label: Text('Buscar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(20),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(child: Icon(Icons.mobile_friendly, size: 80, color: Colors.orange)),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Accede y explora millones de artículos científicos proporcionados por CORE API, una de las fuentes de conocimiento abierto más grandes del mundo.',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
               SizedBox(height: 40),

              Text(
                'Artificial Intelligence in Video Games',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[200],
                ),
              ),
              SizedBox(height: 20),

              Text(
                'Explore topics:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: [
                  _topicLink('Game AI'),
                  _topicLink('Behavior Trees'),
                  _topicLink('Machine Learning'),
                  _topicLink('Pathfinding'),
                  _topicLink('Agent-Based Systems'),
                ],
              ),
              SizedBox(height: 20),

              Text(
                'Discover key research exploring how AI is implemented in modern video games, '
                'from rule-based systems to emergent learning models.',
                style: TextStyle(color: Colors.grey[300]),
              ),
              SizedBox(height: 20),

              Text(
                'Popular Articles',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _articleItem(
                'Artificial Intelligence in Video Games: Towards a Unified Framework',
                'Carvalho et al., 2021 – CORE.ac.uk',
              ),
              _articleItem(
                'Artificial Intelligence for Games',
                'Millington & Funge, 2019 – CORE.ac.uk',
              ),
              _articleItem(
                'Playing Smart - Artificial Intelligence in Computer Games',
                'Anderson, 2003 – CORE.ac.uk',
              ),
              RecommendedSection(),
            ],
          ),
        ),
      ),
    );
  }
}
