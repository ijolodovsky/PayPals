import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';

Future<void> marcarGastosComoPagados(String groupId) async {
  try {
    DocumentReference grupoDocRef = FirebaseFirestore.instance.collection('grupos').doc(groupId);
    DocumentSnapshot grupoDoc = await grupoDocRef.get();

    if (grupoDoc.exists) {
      List<dynamic> expenses = grupoDoc['expenses'];
      List<dynamic> updatedExpenses = expenses.map((expense) {
        if (!expense['paid']) {
          expense['paid'] = true;
        }
        return expense;
      }).toList();

      await grupoDocRef.update({'expenses': updatedExpenses});
    }
  } catch (error) {
    print('Error al marcar los gastos como pagados: $error');
    rethrow;
  }
}

Future<Map<String, double>> calcularBalances(String groupId) async {
  // Obtener los gastos del grupo
  List<Gasto> gastos = await obtenerGastosDeGrupo(groupId);

  // Obtener la lista de miembros del grupo
  DocumentSnapshot groupDoc = await FirebaseFirestore.instance.collection('grupos').doc(groupId).get();
  List<String> miembros = List<String>.from(groupDoc['members'] ?? []);

  // imprimir miembros por consola
  print('Miembros del grupo: $miembros'); // Debugging line

  // Map para almacenar los gastos por persona
  Map<String, double> balance = {};

  // Calcular los gastos por persona
  for (Gasto gasto in gastos) {
    if (!gasto.paid) {
      if (balance.containsKey(gasto.payerId)) {
        balance[gasto.payerId] = balance[gasto.payerId]! + gasto.amount;
      } else {
        balance[gasto.payerId] = gasto.amount;
      }
    }
  }

  // Incluir a todos los miembros, incluso si no han gastado nada
  for (String miembro in miembros) {
    if (!balance.containsKey(miembro)) {
      balance[miembro] = 0.0;
    }
  }

  // Calcular el total de gastos y el gasto equitativo por persona
  double totalGastos = balance.values.fold(0, (sum, item) => sum + item);
  double gastoEquitativo = totalGastos / miembros.length;

  // Calcular los balances
  Map<String, double> balances = {};
  for (String miembro in miembros) {
    double gastoPersona = balance[miembro] ?? 0.0;
    balances[miembro] = gastoPersona - gastoEquitativo;
  }

  return balances;
}

Future<List<Map<String, dynamic>>> ajustarDeudas(String groupId) async {
  print('Iniciando ajuste de deudas para el grupo $groupId'); // Debugging line
  Map<String, double> balances = await calcularBalances(groupId);
  List<Map<String, dynamic>> deudas = [];

  // Listas para los que deben (deudores) y los que deben recibir (acreedores)
  List<MapEntry<String, double>> deudores = balances.entries.where((entry) => entry.value < 0).toList();
  List<MapEntry<String, double>> acreedores = balances.entries.where((entry) => entry.value > 0).toList();

  print('Deudores: $deudores'); // Debugging line
  print('Acreedores: $acreedores'); // Debugging line

  for (int i = 0; i < acreedores.length; i++) {
    String acreedor = acreedores[i].key;
    double acreencia = acreedores[i].value;

    for (int j = 0; j < deudores.length; j++) {
      String deudor = deudores[j].key;
      double deuda = deudores[j].value.abs();

      double monto = deuda < acreencia ? deuda : acreencia;

      deudas.add({
        'deudor': deudor,
        'acreedor': acreedor,
        'monto': monto,
      });

      deudores[j] = MapEntry(deudor, deudores[j].value + monto);
      acreedores[i] = MapEntry(acreedor, acreedores[i].value - monto);

      if (deudores[j].value == 0 && acreedores[i].value == 0) break;
    }
  }
  
  // Imprimir deudas por consola
  for (Map<String, dynamic> deuda in deudas) {
    print('${deuda['deudor']} le debe \$${deuda['monto']} a ${deuda['acreedor']}');
  }
  print('Ajuste de deudas completado.'); // Debugging line
  
  return deudas;
}
