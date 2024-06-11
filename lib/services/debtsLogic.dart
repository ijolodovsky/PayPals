import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';

Future<Map<String, double>> calcularDeudas(String groupId) async {
  List<Gasto> gastos = await obtenerGastosDeGrupo(groupId);

  Map<String, double> balances = {};

  for (Gasto gasto in gastos) {
    if (!gasto.paid) {
      if (balances.containsKey(gasto.payer)) {
        balances[gasto.payer] = balances[gasto.payer]! + gasto.amount;
      } else {
        balances[gasto.payer] = gasto.amount;
      }
    }
  }

  return balances;
}

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

  // Map para almacenar los gastos por persona
  Map<String, double> gastosPorPersona = {};

  // Calcular los gastos por persona
  for (Gasto gasto in gastos) {
    if (!gasto.paid) {
      if (gastosPorPersona.containsKey(gasto.payer)) {
        gastosPorPersona[gasto.payer] = gastosPorPersona[gasto.payer]! + gasto.amount;
      } else {
        gastosPorPersona[gasto.payer] = gasto.amount;
      }
    }
  }

  // Incluir a todos los miembros, incluso si no han gastado nada
  for (String miembro in miembros) {
    if (!gastosPorPersona.containsKey(miembro)) {
      gastosPorPersona[miembro] = 0.0;
    }
  }

  // Calcular el total de gastos y el gasto equitativo por persona
  double totalGastos = gastosPorPersona.values.fold(0, (sum, item) => sum + item);
  double gastoEquitativo = totalGastos / miembros.length;

  // Calcular los balances
  Map<String, double> balances = {};
  for (String miembro in miembros) {
    double gastoPersona = gastosPorPersona[miembro] ?? 0.0;
    balances[miembro] = gastoPersona - gastoEquitativo;
  }

  return balances;
}


List<Map<String, dynamic>> ajustarDeudas(Map<String, double> balances) {
  List<Map<String, dynamic>> deudas = [];

  // Listas para los que deben (deudores) y los que deben recibir (acreedores)
  List<MapEntry<String, double>> deudores = balances.entries.where((entry) => entry.value < 0).toList();
  List<MapEntry<String, double>> acreedores = balances.entries.where((entry) => entry.value > 0).toList();

  int i = 0, j = 0;

  while (i < deudores.length && j < acreedores.length) {
    String deudor = deudores[i].key;
    String acreedor = acreedores[j].key;
    double deuda = deudores[i].value.abs();
    double acreencia = acreedores[j].value;

    double monto = deuda < acreencia ? deuda : acreencia;

    deudas.add({
      'deudor': deudor,
      'acreedor': acreedor,
      'monto': monto,
    });

    deudores[i] = MapEntry(deudor, deudores[i].value + monto);
    acreedores[j] = MapEntry(acreedor, acreedores[j].value - monto);

    if (deudores[i].value == 0) i++;
    if (acreedores[j].value == 0) j++;
  }

  return deudas;
}

