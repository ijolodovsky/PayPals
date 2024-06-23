import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getGroupDocument(String groupId) async {
   
    return await _firestore.collection('grupos').doc(groupId).get();
  }

  Future<void> actualizarGasto(String groupId, String id, Gasto updatedExpense) async {
    //buscar en la coleccion expenses el documento con el id del gasto
    DocumentReference expenseDocRef = _firestore.collection('expenses').doc(id);
    //actualizar el documento con los nuevos datos
    await expenseDocRef.update({
      'description': updatedExpense.description,
      'amount': updatedExpense.amount,
      'date': updatedExpense.date,
      'paid': updatedExpense.paid,
      'payer': updatedExpense.payer,
      'payerId': updatedExpense.payerId,
    });
  }

  Future<void> eliminarGasto(String groupId, String id) {
    //buscar en la coleccion expenses el documento con el id del gasto
    DocumentReference expenseDocRef = _firestore.collection('expenses').doc(id);
    //buscar en el grupo el id del gasto dentro de la lista de expenses
    return _firestore.collection('grupos').doc(groupId).update({
      'expenses': FieldValue.arrayRemove([expenseDocRef.id])
    }).then((_) {
      //eliminar el documento
      return expenseDocRef.delete();
    });
  }
}

Future<String> getUserName(String userId) async {
  final FirestoreService _firestoreService = FirestoreService();
  DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestoreService.getUserDocument(userId);
  if (userDoc.exists) {
    return userDoc.data()!['userName'];
  } else {
    return 'Usuario desconocido';
  }
}