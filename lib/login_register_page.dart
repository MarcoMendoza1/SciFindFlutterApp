import 'package:flutter/material.dart';
import 'package:scifind/app_bar_header.dart';
import 'package:scifind/context/auth_service.dart';


class RegisterLoginScreen extends StatefulWidget {
  final void Function()? onLoginSuccess;

  const RegisterLoginScreen({super.key, this.onLoginSuccess});

  @override
  _RegisterLoginScreenState createState() => _RegisterLoginScreenState();
}

class _RegisterLoginScreenState extends State<RegisterLoginScreen> {
  bool showLogin = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBarHeader(),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minWidth: 200, maxWidth: 600),
            padding: const EdgeInsets.all(24.0),
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  showLogin ? 'Iniciar Sesión' : 'Registro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                if (!showLogin) ...[
                  _buildTextField(controller: nameController, hintText: 'Nombre Completo'),
                  _buildTextField(controller: phoneController, hintText: 'Número de Teléfono'),
                  _buildTextField(controller: addressController, hintText: 'Dirección'),
                ],

                _buildTextField(controller: emailController, hintText: 'Correo Electrónico'),
                _buildTextField(controller: passwordController, hintText: 'Contraseña', obscureText: true),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (showLogin) {
                      final email = emailController.text.trim();
                      final password = passwordController.text;

                      final success = await AuthService.login(email, password);

                      if (success) {
                        // Navega a la pantalla principal
                        if (widget.onLoginSuccess != null) {
                          widget.onLoginSuccess!();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Correo o contraseña incorrectos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Registro aún no implementado.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  ),
                  child: Text(
                    showLogin ? 'Iniciar Sesión' : 'Registrar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showLogin = !showLogin;
                    });
                  },
                  child: Text(
                    showLogin
                        ? '¿No tienes una cuenta? Regístrate'
                        : '¿Ya tienes una cuenta? Inicia Sesión',
                    style: TextStyle(
                      color: Colors.redAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
