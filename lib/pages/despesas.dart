import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DespesasWidget extends StatefulWidget {
  final DateTime? mesSelecionado;

  const DespesasWidget({
    super.key,
    this.mesSelecionado,
  });

  @override
  State<DespesasWidget> createState() => _DespesasWidgetState();
}

class _DespesasWidgetState extends State<DespesasWidget> {
  // --------------------------------------------------
  // NOVA DESPESA
  // --------------------------------------------------

  void _novaDespesa() {
    final nomeController = TextEditingController();
    final valorController = TextEditingController();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova despesa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Despesa',
                  hintText: 'Ex: Água',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nome = nomeController.text.trim();

                final valor = double.tryParse(
                      valorController.text.replaceAll(',', '.'),
                    ) ??
                    0;

                if (nome.isEmpty || valor <= 0) {
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user.uid)
                      .collection('despesas')
                      .add({
                    'nome': nome,
                    'valor': valor,
                    'data': Timestamp.now(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  print('Erro ao salvar despesa: $e');
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // MÊS
  // --------------------------------------------------

  DateTime get mesAtual {
    return widget.mesSelecionado ?? DateTime.now();
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Usuário não encontrado'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('despesas')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Erro ao carregar despesas'),
          );
        }

        final documentos = snapshot.data?.docs ?? [];

        // --------------------------------------------------
        // FILTRA AS DESPESAS DO MÊS
        // --------------------------------------------------

        final despesas = documentos.where((documento) {
          final dados = documento.data() as Map<String, dynamic>;

          final data = dados['data'];

          if (data is! Timestamp) {
            return false;
          }

          final dataDespesa = data.toDate();

          return dataDespesa.year == mesAtual.year &&
              dataDespesa.month == mesAtual.month;
        }).toList();

        // --------------------------------------------------
        // TOTAL
        // --------------------------------------------------

        double total = 0;

        for (final documento in despesas) {
          final dados = documento.data() as Map<String, dynamic>;

          final valor = dados['valor'];

          if (valor is num) {
            total += valor.toDouble();
          }
        }

        // --------------------------------------------------
        // TELA
        // --------------------------------------------------

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // --------------------------------------------------
            // CAIXA DO GRÁFICO
            // --------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.70),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Despesas por categoria',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (despesas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Nenhuma despesa cadastrada.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        //botao despesa
                        ElevatedButton.icon(
                          onPressed: _novaDespesa,
                          icon: const Icon(Icons.add),
                          label: const Text('Nova despesa'),
                          style: ElevatedButton.styleFrom(
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // GRÁFICO
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CustomPaint(
                            painter: GraficoDespesasPainter(
                              despesas: despesas,
                            ),
                            child: Center(
                              child: Text(
                                'R\$ ${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // LEGENDA
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 8,
                          children: despesas.map((documento) {
                            final dados =
                                documento.data() as Map<String, dynamic>;

                            final nome = dados['nome'] ?? '';

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                nome,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 15),

                        // TOTAL
                        Text(
                          'Valor total R\$ ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// GRÁFICO DE pizza

class GraficoDespesasPainter extends CustomPainter {
  final List<QueryDocumentSnapshot> despesas;

  GraficoDespesasPainter({
    required this.despesas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double total = 0;

    for (final documento in despesas) {
      final dados = documento.data() as Map<String, dynamic>;

      final valor = dados['valor'];

      if (valor is num) {
        total += valor.toDouble();
      }
    }

    if (total <= 0) {
      return;
    }

    final centro = Offset(
      size.width / 2,
      size.height / 2,
    );

    final raio = size.width / 2 - 10;

    double inicio = -1.5708;

    final cores = [
      const Color(0xFF8B6BE8),
      const Color(0xFF28C76F),
      const Color(0xFF292D3E),
      const Color(0xFFE35D6A),
      const Color(0xFFF2B84B),
      const Color(0xFF5B9BD5),
    ];

    for (int i = 0; i < despesas.length; i++) {
      final dados = despesas[i].data() as Map<String, dynamic>;

      final valor = dados['valor'];

      if (valor is! num) {
        continue;
      }

      final percentual = valor.toDouble() / total;

      final angulo = percentual * 6.28318;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 38
        ..strokeCap = StrokeCap.butt
        ..color = cores[i % cores.length];

      canvas.drawArc(
        Rect.fromCircle(
          center: centro,
          radius: raio,
        ),
        inicio,
        angulo,
        false,
        paint,
      );

      inicio += angulo;
    }

    // CENTRO BRANCO
    final centroPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      centro,
      raio - 25,
      centroPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GraficoDespesasPainter oldDelegate) {
    return true;
  }
}
