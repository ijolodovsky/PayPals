import 'package:cloud_firestore/cloud_firestore.dart';
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
      'expenses': <Map<String, dynamic>>[],
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
      // Si el documento del usuario existe, obtenemos la lista actual de grupos
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?; // Casting del objeto
      if (userData != null && userData.containsKey('grupos')) {
        // Verificamos que el objeto userData no sea nulo y contenga la propiedad 'grupos'
        grupos = List<String>.from(userData['grupos']); // Accedemos a la propiedad 'grupos' de manera segura
      }
    }

    // Agregamos el nuevo grupo a la lista (si aún no está presente)
    if (!grupos.contains(groupId)) {
      grupos.add(groupId);
    }

    // Actualizamos solo la lista de grupos del usuario
    await userDocRef.set({
      'grupos': grupos,
    }, SetOptions(merge: true)); // Usamos merge: true para fusionar los datos sin reemplazar el documento completo
  } catch (e) {
    print('Error al agregar el grupo al usuario: $e');
    rethrow;
  }
}

