import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_gastos/services/addGroupPageLogic.dart';
import 'package:flutter_app_gastos/widgets/groupCreatedDialog.dart';

class AddGroupPage extends StatefulWidget {
  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String uniqueCode = '';

  void createGroup() async {
    String groupName = groupNameController.text;
    String description = descriptionController.text;

    try {
      String groupId = await crearGrupoEnFirestore(groupName, description);

      // Agregar el ID del grupo a la subcolección "grupos" del usuario actual
      await agregarGrupoAlUsuario(groupId);

      setState(() {
        uniqueCode = groupId;
      });
    } catch (e) {
      print('Error al crear el grupo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el grupo')),
      );
    }
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: uniqueCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código copiado al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Grupo de Gastos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                  hintText: 'Nombre del Grupo',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Descripción del Grupo',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Crear Grupo'),
                onPressed: createGroup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
