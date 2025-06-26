import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scifind/context/auth_service.dart';
import 'package:scifind/context/session_model.dart';
import 'package:scifind/user_history.dart';

class AppBarHeader extends StatelessWidget implements PreferredSizeWidget{
  const AppBarHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sesion = Provider.of<SesionModel>(context);
    
    return AppBar(
      backgroundColor: Colors.purple[800],
      title: Row(
        children: [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'SciFind',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.brightness_5, color: Colors.white),
          onPressed: () {
            
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.router, color: Colors.white),
            onPressed: () => _dialogBuilder(context),
          ),
        ),
        if(sesion.estaAutenticado)
        PopupMenuButton<String>(
          icon: Icon(Icons.settings, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'historial':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserHistoryScreen(userId:int.parse(sesion.usuario!['id']))),
                );
                break;
              case 'cerrar':
                sesion.cerrarSesion();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'historial',
              child: Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 10),
                  Text('Ver historial'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'cerrar',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 10),
                  Text('Cerrar sesión'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    final TextEditingController ipController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar IP'),
          content: const Text(
            'Introduzca la direccion IP del servidor',
          ),
          actions: <Widget>[
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                hintText: 'Ej: localhost',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('Guardar'),
              onPressed: () async {
                await AuthService.setBaseUrl(ipController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
