import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentosPage extends StatelessWidget {
  const DocumentosPage({super.key});

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0E5A43),
        onPressed: () {
          _mostrarDialogo(context);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .collection('documentos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum documento cadastrado',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return DocumentoItem(
                nome: data['nome'],
                url: data['url'],
                docId: docs[index].id,
              );
            },
          );
        },
      ),
    );
  }

  // 🔥 DIALOG + UPLOAD
  void _mostrarDialogo(BuildContext context) {
    final nomeController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    File? arquivoSelecionado;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Novo Documento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      hintText: 'Nome do documento',
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();

                      if (result != null) {
                        arquivoSelecionado = File(result.files.single.path!);
                        setState(() {});
                      }
                    },
                    child: const Text('Selecionar arquivo'),
                  ),
                  if (arquivoSelecionado != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('Arquivo selecionado'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (arquivoSelecionado == null) return;

                    final nomeArquivo =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('documentos')
                        .child(user!.uid)
                        .child(nomeArquivo);

                    await ref.putFile(arquivoSelecionado!);

                    final url = await ref.getDownloadURL();

                    await FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(user.uid)
                        .collection('documentos')
                        .add({
                      'nome': nomeController.text,
                      'url': url,
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// 🔥 ITEM
class DocumentoItem extends StatelessWidget {
  final String nome;
  final String url;
  final String docId;

  const DocumentoItem({
    super.key,
    required this.nome,
    required this.url,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(
          Icons.insert_drive_file,
          color: Color(0xFF0E5A43),
        ),
        title: Text(nome),

        // 🔥 ABRIR DOCUMENTO
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },

        // 🔥 DELETAR
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user!.uid)
                .collection('documentos')
                .doc(docId)
                .delete();
          },
        ),
      ),
    );
  }
}
