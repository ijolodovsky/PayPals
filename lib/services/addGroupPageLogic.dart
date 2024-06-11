import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';
import 'package:flutter_app_gastos/user_auth/firebase_user_authentication/fire_auth_services.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<String> crearGrupoEnFirestore(String groupName, String description) async {
  try {
    // Obtener una referencia a la colección de grupos en Firestore
    CollectionReference gruposCollection = FirebaseFirestore.instance.collection('grupos');

    // Crear un nuevo documento en la colección de grupos
    DocumentReference nuevoGrupoRef = await gruposCollection.add({
      'groupName': groupName,
      'description': description,
      'expenses': <Gasto>[],
      'members': <String>[obtenerIdUsuarioActual()],
    });

    // Devolver el ID del documento recién creado como identificador único del grupo
    return nuevoGrupoRef.id;
  } catch (error) {
    // Manejar cualquier error que ocurra durante la creación del grupo
    print('Error al crear el grupo en Firestore: $error');
    rethrow;
  }
}
Future<void> agregarGrupoAlUsuario(String groupId) async {
  try {
    String userId = obtenerIdUsuarioActual();
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // Obtenemos la lista actual de grupos del usuario (si existe)
    DocumentSnapshot userDoc = await userDocRef.get();
    List<String> grupos = [];
    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('grupos')) {
        grupos = List<String>.from(userData['grupos']);
      }
    }

    // Agregamos el nuevo grupo a la lista (si no esta presente)
    if (!grupos.contains(groupId)) {
      grupos.add(groupId);
    }

    // Actualizamos solo la lista de grupos del usuario
    await userDocRef.set({
      'grupos': grupos,
    }, SetOptions(merge: true));
  } catch (e) {
    print('Error al agregar el grupo al usuario: $e');
    rethrow;
  }
}

Future<void> agregarUsuarioAlGrupo(String groupId) async {
  try {
    String userId = obtenerIdUsuarioActual();
    DocumentReference groupDocRef = FirebaseFirestore.instance.collection('grupos').doc(groupId);

    // Obtenemos la lista actual de grupos del usuario (si existe)
    DocumentSnapshot groupDoc = await groupDocRef.get();
    List<String> miembros = [];
    if (groupDoc.exists) {
      //obtener lista de miembros
      miembros = List<String>.from(groupDoc['members']);
      if(!miembros.contains(userId)){
        miembros.add(userId);
      }
      // Actualizamos solo la lista de grupos del usuario
      await groupDocRef.set({
        'members': miembros,
      }, SetOptions(merge: true));
    }
  } catch (e) {
    print('Error al usuario al grupo: $e');
    rethrow;
  }
}