import 'package:flutter/material.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  DateTime mesSelecionado = DateTime.now();
  double valor = 1700.00;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Parte superior
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão voltar
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),

                // Mês e valor
                Column(
                  children: [
                    Text(
                      nomeDoMes(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'R\$ ${valor.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),

                // Botão editar
                IconButton(
                  onPressed: () async {
                    DateTime? novaData = await showDatePicker(
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
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
