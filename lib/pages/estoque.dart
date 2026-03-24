import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstoquePage extends StatelessWidget {
  const EstoquePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // BOTÃO ADICIONAR ITEM
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0E5A43),
        child: const Icon(Icons.add),
        onPressed: () {
          _mostrarDialogo(context);
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .collection('estoque')
            .snapshots(),
        builder: (context, snapshot) {
          // carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final itens = snapshot.data?.docs ?? [];

          // vazio
          if (itens.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum item no estoque',
                style: TextStyle(fontSize: 22),
              ),
            );
          }

          // lista
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: itens.length,
            itemBuilder: (context, index) {
              final item = itens[index];
              final data = item.data() as Map<String, dynamic>;

              return EstoqueItem(
                nome: data['nome'],
                quantidade: data['quantidade'],
                docId: item.id,
                imagem: data['imagem'] ?? 'assets/images/alface.png',
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    final nomeController = TextEditingController();
    final quantidadeController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    String imagemSelecionada = 'assets/images/alface.png';

    final imagens = [
      'assets/images/alface.png',
      'assets/images/ovo.png',
      'assets/images/leite.png',
      'assets/images/cebola.png',
      'assets/images/batata.png',
      'assets/images/cenoura.png',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Novo Item'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(hintText: 'Nome'),
                    ),
                    TextField(
                      controller: quantidadeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Quantidade'),
                    ),
                    const SizedBox(height: 15),
                    const Text('Escolha uma imagem'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: imagens.map((img) {
                        final selecionado = img == imagemSelecionada;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              imagemSelecionada = img;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selecionado
                                    ? Colors.green
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              img,
                              width: 45,
                              height: 45,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(user!.uid)
                        .collection('estoque')
                        .add({
                      'nome': nomeController.text,
                      'quantidade':
                          int.tryParse(quantidadeController.text) ?? 0,
                      'imagem': imagemSelecionada,
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class EstoqueItem extends StatelessWidget {
  final String nome;
  final int quantidade;
  final String docId;
  final String imagem;

  const EstoqueItem({
    super.key,
    required this.nome,
    required this.quantidade,
    required this.docId,
    required this.imagem,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.27),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            imagem,
            width: 53,
            height: 53,
          ),

          const SizedBox(width: 10),

          //  NOME
          Expanded(
            child: Text(
              nome,
              style: const TextStyle(fontSize: 23),
            ),
          ),

          // CONTROLES
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () async {
                  if (quantidade > 0) {
                    await FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(user!.uid)
                        .collection('estoque')
                        .doc(docId)
                        .update({
                      'quantidade': quantidade - 1,
                    });
                  }
                },
              ),

              Text(
                quantidade.toString(),
                style: const TextStyle(fontSize: 19),
              ),

              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user!.uid)
                      .collection('estoque')
                      .doc(docId)
                      .update({
                    'quantidade': quantidade + 1,
                  });
                },
              ),

              //  BOTÃO DELETAR
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user!.uid)
                      .collection('estoque')
                      .doc(docId)
                      .delete();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
