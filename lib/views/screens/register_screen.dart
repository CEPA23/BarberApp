import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();

      if (password == confirmPassword) {
        // Aquí luego llamaremos al servicio de Firebase para registrar al usuario
        print("Registrando usuario: $name, $email");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Crear Cuenta",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Regístrate para empezar a usar la app",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: "Nombre completo",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _emailController,
                        label: "Correo electrónico",
                        icon: Icons.email,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Contraseña",
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: "Confirmar contraseña",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.greenAccent,
                        ),
                        child: const Text(
                          'REGISTRARSE',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.greenAccent),
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (isPassword && value.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        return null;
      },
    );
  }
}
