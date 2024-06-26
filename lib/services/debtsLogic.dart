import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';

Future<void> marcarGastosComoPagados(String groupId) async {
  try {
    // Obtener el documento del grupo
    DocumentReference grupoDocRef = FirebaseFirestore.instance.collection('grupos').doc(groupId);
    DocumentSnapshot grupoDoc = await grupoDocRef.get();

    if (grupoDoc.exists) {
      List<dynamic> expenseIds = grupoDoc['expenses'];

      // Recorrer cada ID de gasto y actualizar el campo 'paid' a true
      for (String expenseId in expenseIds) {
        DocumentReference expenseDocRef = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
        DocumentSnapshot expenseDoc = await expenseDocRef.get();

        if (expenseDoc.exists && !expenseDoc['paid']) {
          await expenseDocRef.update({'paid': true});
        }
      }
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

    if (deuda < acreencia) {
      acreedores[j] = MapEntry(acreedor, acreencia - deuda);
      i++;
    } else if (deuda > acreencia) {
      deudores[i] = MapEntry(deudor, -(deuda - acreencia));
      j++;
    } else {
      i++;
      j++;
    }
  }

  print('Deudas calculadas: $deudas'); // Debugging line
  return deudas;
}

Future<Map<String, double>> obtenerBalanceUsuario(String userId, String groupId) async {
  Map<String, double> balances = await calcularBalances(groupId);
  double balance = balances[userId] ?? 0.0;
  double totalDeuda = 0.0;
  double totalAcreedor = 0.0;

  // Calcular total de deudas y créditos del usuario
  for (var entry in balances.entries) {
    if (entry.key == userId) {
      if (entry.value < 0) {
        totalDeuda += entry.value.abs();
      } else if (entry.value > 0) {
        totalAcreedor += entry.value;
      }
    }
  }

  return {
    'balance': balance,
    'totalDeuda': totalDeuda,
    'totalAcreedor': totalAcreedor,
  };
}
