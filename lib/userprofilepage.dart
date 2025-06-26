import 'package:flutter/material.dart';
import 'package:scifind/context/auth_service.dart';

class UserProfileScreen extends StatefulWidget {

  UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController emailController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getUser();

    nameController = TextEditingController(text: user?['name'] ?? '');
    phoneController = TextEditingController(text: user?['phone'] ?? '');
    addressController = TextEditingController(text: user?['address'] ?? '');
    emailController = TextEditingController(text: user?['email'] ?? '');

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    final user = await AuthService.getUser();
    if (user == null) return;

    final success = await AuthService.updateUserProfile(
      id: user['id'],
      name: nameController.text,
      phone: phoneController.text,
      address: addressController.text,
      email: emailController.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Cambios guardados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar los cambios'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 700;
        
            return isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  isSmallScreen
                      ? Column(
                          children: [
                            _buildProfileImage(),
                            const SizedBox(height: 20),
                            _buildUserInfoForm(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildProfileImage()),
                            const SizedBox(width: 40),
                            Expanded(flex: 2, child: _buildUserInfoForm()),
                          ],
                        ),
                  const SizedBox(height: 40),
                  Divider(color: Colors.grey[600]),
                  const SizedBox(height: 20),
                  Text(
                    'Este sitio utiliza cookies para mejorar la experiencia del usuario.',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Todo el contenido de este sitio está protegido por derechos de autor © 2025. Todos los derechos reservados. '
                    'El uso de este contenido, incluyendo minería de datos, entrenamiento de inteligencia artificial u otras tecnologías similares, '
                    'está sujeto a restricciones legales. Para el contenido de acceso abierto, aplican los términos de licencia correspondientes.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/profile.jpg',
            width: 200,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            // lógica para seleccionar archivo
          },
          icon: Icon(Icons.upload),
          label: Text('Subir foto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[800],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mi Perfil",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.pink[200],
          ),
        ),
        const SizedBox(height: 16),
        _buildLabeledField("Nombre:", nameController),
        _buildLabeledField("Teléfono:", phoneController),
        _buildLabeledField("Dirección:", addressController),
        _buildLabeledField("Correo electrónico:", emailController),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: Icon(Icons.save),
              label: Text("Guardar cambios"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[800],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                // ver historial
              },
              icon: Icon(Icons.history),
              label: Text("Ver historial"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
