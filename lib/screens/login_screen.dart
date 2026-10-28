import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'driver_home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final success = await AuthService.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        // Récupérer le rôle enregistré par AuthService
        final role = await AuthService.getUserRole();

        print('ROLE UTILISATEUR : $role');

        if (!mounted) return;

        // Redirection selon le rôle
        if (role == 'DRIVER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverHomePage(),
            ),
          );
        } else if (role == 'PASSENGER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else if (role == 'ADMIN') {
          setState(() {
            errorMessage = 'La page administrateur n’est pas encore disponible.';
          });
        } else {
          setState(() {
            errorMessage = 'Rôle utilisateur inconnu.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Nom d’utilisateur ou mot de passe incorrect.';
        });
      }
    } catch (e) {
      print('ERREUR LOGIN : $e');

      if (mounted) {
        setState(() {
          errorMessage = 'Une erreur est survenue.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 120,
              width: 120,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d’utilisateur',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (errorMessage != null)
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}