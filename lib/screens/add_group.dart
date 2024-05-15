import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importa esta librería

class AddGroupPage extends StatefulWidget {
  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String uniqueCode = ''; // Cambio aquí: inicializo uniqueCode como una cadena vacía

  String generateUniqueCode() {
    // Lógica para generar un código único (puede ser más compleja en producción)
    return 'ABCD123'; // Ejemplo: código hardcodeado
  }

  void createGroup() {
    // Implementar la lógica para crear un nuevo grupo de gastos
    uniqueCode = generateUniqueCode();
    print('Código único generado: $uniqueCode');
    // Aquí puedes guardar los datos en la base de datos
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: uniqueCode)); // Copia el código al portapapeles
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
              // Campos de texto para nombre y descripción del grupo
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
                onPressed: () {
                  createGroup();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Grupo Creado'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Código único: $uniqueCode'),
                            SizedBox(height: 10),
                            IconButton(
                              onPressed: copyToClipboard, // Copia el código al portapapeles
                              icon: Icon(Icons.copy), // Icono de copiar
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
