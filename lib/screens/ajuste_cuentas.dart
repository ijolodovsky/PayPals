import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/FirestoreService.dart';
import 'package:flutter_app_gastos/services/debtsLogic.dart';

class AjustarCuentas extends StatelessWidget {
  final String groupId;

  AjustarCuentas({required this.groupId});

  Future<List<Map<String, dynamic>>> _obtenerDeudasConNombres(String groupId) async {
    List<Map<String, dynamic>> deudas = await ajustarDeudas(groupId);

    for (var deuda in deudas) {
      deuda['deudor'] = await getUserName(deuda['deudor']);
      deuda['acreedor'] = await getUserName(deuda['acreedor']);
    }

    return deudas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustar cuentas'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _obtenerDeudasConNombres(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al calcular las deudas: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> deudas = snapshot.data!;
            return ListView.builder(
              itemCount: deudas.length,
              itemBuilder: (context, index) {
                String deudor = deudas[index]['deudor'];
                String acreedor = deudas[index]['acreedor'];
                double monto = deudas[index]['monto'];
                return ListTile(
                  title: Text('$deudor le debe \$${monto.toStringAsFixed(2)} a $acreedor'),
                );
              },
            );
          } else {
            return Center(child: Text('No hay deudas que ajustar.'));
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