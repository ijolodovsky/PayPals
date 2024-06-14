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
            if (deudas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handshake,
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Deudas entre Pals saldadas',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: deudas.length,
                itemBuilder: (context, index) {
                  String deudor = deudas[index]['deudor'];
                  String acreedor = deudas[index]['acreedor'];
                  double monto = deudas[index]['monto'];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(deudor[0]),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      title: Text(
                        deudor,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      subtitle: Text(
                        'le debe \$${monto.toStringAsFixed(2)} a $acreedor',
                        style: TextStyle(color: Colors.black54),
                      ),
                      trailing: CircleAvatar(
                        child: Text(acreedor[0]),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      onTap: () {},
                    ),
                  );
                },
              );
            }
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
