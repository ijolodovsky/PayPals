import 'package:flutter/material.dart';

class GroupCreatedDialog extends StatelessWidget {
  final String uniqueCode;
  final Function copyToClipboard;

  GroupCreatedDialog({required this.uniqueCode, required this.copyToClipboard, required void Function() shareCode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Grupo Creado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Código único: $uniqueCode'),
          SizedBox(height: 10),
          IconButton(
            onPressed: () {
              copyToClipboard(); // Copia el código al portapapeles
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            icon: Icon(Icons.copy), // Icono de copiar
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo
          },
          child: Text('Aceptar'),
        ),
      ],
    );
  }
}
