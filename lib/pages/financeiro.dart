import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  DateTime mesSelecionado = DateTime.now();

  // ============================================================
  // NOME DO MÊS
  // ============================================================

  String nomeDoMes() {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return meses[mesSelecionado.month - 1];
  }

  // ============================================================
  // ESCOLHER O MÊS
  // ============================================================

  Future<void> selecionarMes() async {
    final novaData = await showDatePicker(
      context: context,
      initialDate: mesSelecionado,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (novaData != null) {
      setState(() {
        mesSelecionado = novaData;
      });
    }
  }

  // ============================================================
  // VERIFICA SE A VENDA É DO MÊS SELECIONADO
  // ============================================================

  bool vendaDoMes(Map<String, dynamic> data) {
    if (data['data'] == null) {
      return false;
    }

    final dataVenda = (data['data'] as Timestamp).toDate();

    return dataVenda.year == mesSelecionado.year &&
        dataVenda.month == mesSelecionado.month;
  }

  // ============================================================
  // CALCULA O TOTAL
  // ============================================================

  double calcularTotal(List<QueryDocumentSnapshot> vendas) {
    double total = 0;

    for (var venda in vendas) {
      final data = venda.data() as Map<String, dynamic>;

      final valor = data['valor'];

      if (valor is num) {
        total += valor.toDouble();
      }
    }

    return total;
  }

  // ============================================================
  // TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não está logado.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EF),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .collection('vendas')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Erro ao carregar as vendas.',
                ),
              );
            }

            final documentos = snapshot.data?.docs ?? [];

            // Pega somente as vendas do mês selecionado
            final vendasDoMes = documentos.where((documento) {
              final data = documento.data() as Map<String, dynamic>;

              return vendaDoMes(data);
            }).toList();

            final total = calcularTotal(vendasDoMes);

            return Column(
              children: [
                // ==================================================
                // PARTE SUPERIOR
                // ==================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // BOTÃO VOLTAR
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),

                      // MÊS E TOTAL
                      Column(
                        children: [
                          Text(
                            nomeDoMes(),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'R\$ ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // BOTÃO EDITAR
                      IconButton(
                        onPressed: selecionarMes,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // BOTÃO NOVA VENDA
                // ==================================================

                ElevatedButton.icon(
                  onPressed: () {
                    mostrarNovaVenda(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Nova venda',
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // GRÁFICO
                // ==================================================

                Expanded(
                  child: vendasDoMes.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma venda neste mês.',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        )
                      : GraficoVendas(
                          vendas: vendasDoMes,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CADASTRAR NOVA VENDA
  // ============================================================

  void mostrarNovaVenda(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final valorController = TextEditingController();

    String? produtoSelecionado;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Nova venda',
              ),
              content: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(user.uid)
                    .collection('estoque')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final produtos = snapshot.data?.docs ?? [];

                  if (produtos.isEmpty) {
                    return const Text(
                      'Nenhum produto cadastrado no estoque.',
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =================================================
                      // PRODUTO
                      // =================================================

                      DropdownButtonFormField<String>(
                        value: produtoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Produto',
                          border: OutlineInputBorder(),
                        ),
                        items: produtos.map((produto) {
                          final data = produto.data() as Map<String, dynamic>;

                          final nome = data['nome'] ?? '';

                          return DropdownMenuItem<String>(
                            value: nome.toString(),
                            child: Text(
                              nome.toString(),
                            ),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setStateDialog(() {
                            produtoSelecionado = valor;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      // =================================================
                      // VALOR
                      // =================================================

                      TextField(
                        controller: valorController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Valor da venda',
                          hintText: 'Ex: 50,00',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                // CANCELAR
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancelar',
                  ),
                ),

                // SALVAR
                ElevatedButton(
                  onPressed: () async {
                    if (produtoSelecionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Escolha um produto.',
                          ),
                        ),
                      );

                      return;
                    }

                    final valorTexto =
                        valorController.text.replaceAll(',', '.');

                    final valor = double.tryParse(valorTexto);

                    if (valor == null || valor <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Digite um valor válido.',
                          ),
                        ),
                      );

                      return;
                    }

                    try {
                      // ================================================
                      // SALVA A VENDA NO FIREBASE
                      // ================================================

                      await FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(user.uid)
                          .collection('vendas')
                          .add({
                        'produto': produtoSelecionado,
                        'valor': valor,
                        'data': Timestamp.now(),
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro ao salvar venda: $e',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Salvar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ================================================================
// GRÁFICO
// ================================================================

class GraficoVendas extends StatelessWidget {
  final List<QueryDocumentSnapshot> vendas;

  const GraficoVendas({
    super.key,
    required this.vendas,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, double> valoresPorProduto = {};

    for (var venda in vendas) {
      final data = venda.data() as Map<String, dynamic>;

      final produto = data['produto']?.toString() ?? 'Outro';
      final valor = data['valor'];

      if (valor is num) {
        valoresPorProduto[produto] =
            (valoresPorProduto[produto] ?? 0) + valor.toDouble();
      }
    }

    if (valoresPorProduto.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma venda neste mês.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // GRÁFICO
        SizedBox(
          width: 360,
          height: 360,
          child: CustomPaint(
            painter: GraficoPizzaPainter(
              valores: valoresPorProduto,
            ),
            child: Center(
              child: Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'R\$ ${valoresPorProduto.values.fold(0.0, (a, b) => a + b).toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),

        // LEGENDA DOS PRODUTOS
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: valoresPorProduto.keys.map((produto) {
            final index = valoresPorProduto.keys.toList().indexOf(produto);

            final cores = [
              const Color(0xFF2ECC71),
              const Color(0xFF8E6CEF),
              const Color(0xFF292D3E),
              const Color(0xFFE67E22),
              const Color(0xFFE74C3C),
              const Color(0xFF3498DB),
              const Color(0xFFF1C40F),
              const Color(0xFF1ABC9C),
            ];

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: cores[index % cores.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    produto,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ================================================================
// PAINTER DO GRÁFICO
// ================================================================

class GraficoPizzaPainter extends CustomPainter {
  final Map<String, double> valores;

  GraficoPizzaPainter({
    required this.valores,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = valores.values.fold(
      0.0,
      (soma, valor) => soma + valor,
    );

    if (total == 0) {
      return;
    }

    final centro = Offset(
      size.width / 2,
      size.height / 2,
    );

    final raio = 140.0;

    final cores = [
      const Color(0xFF2ECC71),
      const Color(0xFF8E6CEF),
      const Color(0xFF292D3E),
      const Color(0xFFE67E22),
      const Color(0xFFE74C3C),
      const Color(0xFF3498DB),
      const Color(0xFFF1C40F),
      const Color(0xFF1ABC9C),
    ];

    double inicio = -1.5708;

    int index = 0;

    for (final entrada in valores.entries) {
      final produto = entrada.key;
      final valor = entrada.value;

      final porcentagem = valor / total;
      final angulo = porcentagem * 2 * 3.14159265359;

      final cor = cores[index % cores.length];

      // ==========================================
      // FATIA
      // ==========================================

      final paint = Paint()
        ..color = cor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(
          center: centro,
          radius: raio,
        ),
        inicio,
        angulo,
        true,
        paint,
      );

      // ==========================================
      // VALOR DA FATIA
      // ==========================================

      final meioAngulo = inicio + angulo / 2;

      final posicaoValor = Offset(
        centro.dx + (raio * 0.72) * cos(meioAngulo),
        centro.dy + (raio * 0.72) * sin(meioAngulo),
      );

      final textoValor = 'R\$ ${valor.toStringAsFixed(0)}';

      final textPainter = TextPainter(
        text: TextSpan(
          text: textoValor,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final caixaValor = Rect.fromCenter(
        center: posicaoValor,
        width: textPainter.width + 12,
        height: textPainter.height + 8,
      );

      final fundoValor = Paint()..color = Colors.white.withOpacity(0.85);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          caixaValor,
          const Radius.circular(15),
        ),
        fundoValor,
      );

      textPainter.paint(
        canvas,
        Offset(
          posicaoValor.dx - textPainter.width / 2,
          posicaoValor.dy - textPainter.height / 2,
        ),
      );

      // ==========================================
      // PRÓXIMA FATIA
      // ==========================================

      inicio += angulo;

      index++;
    }

    // ==========================================
    // FURO CENTRAL
    // ==========================================

    final centroPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      centro,
      38,
      centroPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant GraficoPizzaPainter oldDelegate,
  ) {
    return oldDelegate.valores != valores;
  }
}
