import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getGroupDocument(String groupId) async {
    return await _firestore.collection('grupos').doc(groupId).get();
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