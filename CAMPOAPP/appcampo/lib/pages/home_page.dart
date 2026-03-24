import 'package:flutter/material.dart';
import 'package:appcampo/pages/cards.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appcampo/pages/estoque.dart';
import 'package:appcampo/pages/documentos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EF),

      body: Column(
        children: [
          const SizedBox(height: 70),

          // BARRA DE PESQUISA
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Pesquisar',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // GRID DE CARDS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 19,
                children: [
                  HomeCard(
                    icon: Icons.attach_money,
                    title: 'Financeiro',
                    onTap: () {},
                  ),
                  HomeCard(
                    icon: Icons.inventory_2,
                    title: 'Estoque',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EstoquePage(),
                        ),
                      );
                    },
                  ),
                  HomeCard(
                    icon: Icons.menu_book,
                    title: 'Catálogo',
                    onTap: () {},
                  ),
                  HomeCard(
                    icon: Icons.sync_alt,
                    title: 'Transações',
                    onTap: () {},
                  ),
                  HomeCard(
                    icon: Icons.school,
                    title: 'Educação Financeira',
                    onTap: () {},
                  ),
                  HomeCard(
                    icon: Icons.folder,
                    title: 'Documentos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DocumentosPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // BARRA INFERIOR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedItemColor: const Color(0xFF0E5A43),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notificações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            // PERFIL CLICADO
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Perfil"),
                content: const Text("Deseja sair da conta?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text(
                      "Deslogar",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}
