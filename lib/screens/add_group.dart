import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_gastos/services/addGroupPageLogic.dart';
import 'package:flutter_app_gastos/widgets/groupCreatedDialog.dart';
import 'package:flutter_app_gastos/screens/group.dart';

class AddGroupPage extends StatefulWidget {
  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String uniqueCode = '';
  bool isLoading = false;

  void createGroup() async {
    String groupName = groupNameController.text;
    String description = descriptionController.text;

    setState(() {
      isLoading = true;
    });

    try {
      String groupId = await crearGrupoEnFirestore(groupName, description);

      await agregarGrupoAlUsuario(groupId);

      setState(() {
        uniqueCode = groupId;
        isLoading = false;
      });

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return GroupCreatedDialog(
            uniqueCode: uniqueCode,
            copyToClipboard: copyToClipboard
          );
        },
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GroupScreen(groupName: groupName, groupId: groupId),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

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
              Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: ColorTween(
                      begin: Colors.blue,
                      end: isLoading ? Colors.blue.withOpacity(0.5) : Colors.blue,
                    ),
                    duration: Duration(milliseconds: 300),
                    builder: (context, Color? color, child) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          minimumSize: Size(200, 50),
                        ),
                        onPressed: isLoading ? null : createGroup,
                        child: child,
                      );
                    },
                    child: Text('Crear Grupo', style: TextStyle(color: Colors.white)),
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
