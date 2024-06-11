import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/debtsLogic.dart';

class AjustarCuentas extends StatelessWidget {
  final String groupId;

  AjustarCuentas({required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustar cuentas'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: calcularDeudas(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al calcular las deudas: ${snapshot.error}'));
          } else {
            Map<String, double> balances = snapshot.data!;
            return ListView.builder(
              itemCount: balances.length,
              itemBuilder: (context, index) {
                String payer = balances.keys.elementAt(index);
                double amount = balances[payer]!;
                return ListTile(
                  title: Text('$payer debe \$${amount.toStringAsFixed(2)}'),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await marcarGastosComoPagados(groupId);
          Navigator.pop(context);
        },
        child: Icon(Icons.payment),
        tooltip: 'Pagar todo',
      ),
    );
  }
}


