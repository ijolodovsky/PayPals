import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/FirestoreService.dart';
import 'package:flutter_app_gastos/services/debtsLogic.dart';
import 'package:url_launcher/url_launcher.dart';

class AjustarCuentas extends StatelessWidget {
  final String groupId;
  final String groupName; // Asumiendo que tienes el nombre del grupo

  AjustarCuentas({required this.groupId, required this.groupName});

  Future<List<Map<String, dynamic>>> _obtenerDeudasConNombres(String groupId) async {
    List<Map<String, dynamic>> deudas = await ajustarDeudas(groupId);

    for (var deuda in deudas) {
      deuda['deudor'] = await getUserName(deuda['deudor']);
      deuda['acreedor'] = await getUserName(deuda['acreedor']);
    }

    return deudas;
  }

  Future<void> _shareOnWhatsApp(List<Map<String, dynamic>> deudas) async {
    String message = 'Hola, Pals!\n\nRecuerden que todavía deben ajustar sus cuentas de $groupName:\n';
    
    for (var deuda in deudas) {
      message += '- ${deuda['deudor']} le debe \$${deuda['monto'].toStringAsFixed(2)} a ${deuda['acreedor']}\n';
    }

    message += '\n¡Desde la app pueden ver los gastos y marcarlos como saldados!';

    final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');

    if (await canLaunch(whatsappUrl.toString())) {
      await launch(whatsappUrl.toString());
    } else {
      throw 'Could not launch WhatsApp';
    }
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
                    Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(30),
                      child: Image.asset('assets/images/saldado.jpg'),
                    ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await marcarGastosComoPagados(groupId);
              Navigator.pop(context, true);  // Pasar 'true' al pop para indicar que se saldaron las deudas
            },
            tooltip: 'Gastos saldados',
            child: Icon(Icons.check),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              List<Map<String, dynamic>> deudas = await _obtenerDeudasConNombres(groupId);
              _shareOnWhatsApp(deudas);
            },
            tooltip: 'Compartir en WhatsApp',
            child: Icon(Icons.share),
          ),
        ],
      ),
    );
  }
}
