import 'package:flutter/material.dart';

class JoinGroupDialog extends StatefulWidget {
  final Function(String) onJoin;

  JoinGroupDialog({required this.onJoin});

  @override
  _JoinGroupDialogState createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<JoinGroupDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Unirse a un Grupo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Código del Grupo',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            widget.onJoin(_controller.text);
            Navigator.of(context).pop();
          },
          child: Text('Aceptar'),
        ),
      ],
    );
  }
}
