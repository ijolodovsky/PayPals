import 'package:cloud_firestore/cloud_firestore.dart';
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
    DocumentReference expenseDocRef = _firestore.collection('expenses').doc(id);
    await expenseDocRef.update({
      'description': updatedExpense.description,
      'amount': updatedExpense.amount,
      'date': updatedExpense.date,
      'paid': updatedExpense.paid,
      'payer': updatedExpense.payer,
      'payerId': updatedExpense.payerId,
      'category': updatedExpense.category,
    });
  }

  Future<void> eliminarGasto(String groupId, String id) {
    DocumentReference expenseDocRef = _firestore.collection('expenses').doc(id);
    return _firestore.collection('grupos').doc(groupId).update({
      'expenses': FieldValue.arrayRemove([expenseDocRef.id])
    }).then((_) {
      return expenseDocRef.delete();
    });
  }

  Future<void> removeUserFromGroup(String groupId, String userId) async {
    DocumentReference groupDocRef = _firestore.collection('grupos').doc(groupId);
    DocumentSnapshot groupDoc = await groupDocRef.get();

    if (groupDoc.exists) {
      List<String> miembros = List<String>.from(groupDoc['members']);
      if (miembros.contains(userId)) {
        miembros.remove(userId);
        await groupDocRef.update({'members': miembros});
      }
    }
  }

  Future<void> removeGroupFromUser(String groupId, String userId) async {
    DocumentReference userDocRef = _firestore.collection('users').doc(userId);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists) {
      List<String> grupos = List<String>.from(userDoc['grupos']);
      if (grupos.contains(groupId)) {
        grupos.remove(groupId);
        await userDocRef.update({'grupos': grupos});
      }
    }
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
