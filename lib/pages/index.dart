import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appcampo/pages/login.dart';
import 'package:appcampo/pages/home_page.dart';
import 'package:appcampo/pages/cadastro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> fazerLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Erro ao fazer login"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E5A43), Color(0xFF083C2E)],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 70),
              Image.asset(
                'assets/images/logoCampo.png',
                height: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),
              const Text(
                'Faça Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              Login(
                hintText: 'Email',
                controller: emailController,
              ),
              const SizedBox(height: 14),
              Login(
                hintText: 'Senha',
                isPasswordField: true,
                controller: senhaController,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 280,
                height: 50,
                child: ElevatedButton(
                  onPressed: fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E5A43),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 280,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Cadastro(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0E5A43), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
