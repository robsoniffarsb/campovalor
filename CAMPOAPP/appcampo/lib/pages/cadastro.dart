import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> criarUsuario() async {
    try {
      // 🔥 Cria usuário no Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      // 🔥 Salva dados extras no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'nome': usuarioController.text.trim(),
        'email': emailController.text.trim(),
        'criadoEm': Timestamp.now(),
      });

      // 🔥 Vai direto para Home e remove todas as telas anteriores
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Erro ao criar usuário"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FUNDO VERDE
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0E5A43), Color(0xFF083C2E)],
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 60),

              // BOTÃO VOLTAR
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // LOGO
              SizedBox(
                height: 220,
                child: Image.asset(
                  'assets/images/logoCampo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // CONTAINER BRANCO
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          "Cadastre-se",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _campo(
                          controller: usuarioController,
                          hint: "Usuário",
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 12),
                        _campo(
                          controller: emailController,
                          hint: "Email",
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 12),
                        _campo(
                          controller: senhaController,
                          hint: "Senha",
                          icon: Icons.lock,
                          isPassword: true,
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: 160,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: criarUsuario,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E5A43),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Criar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Divider(thickness: 1),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton("assets/images/facebook.png"),
                            const SizedBox(width: 20),
                            _socialButton("assets/images/google.png"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF89B2A8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialButton(String asset) {
    return InkWell(
      onTap: () {},
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(asset),
        ),
      ),
    );
  }
}
