import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String serverKey = 'YOUR_SERVER_KEY'; // Reemplaza con tu Server Key de Firebase
  final String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  Future<void> sendNotification(double amount, String description, String token) async {
    try {
      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': 'Nuevo gasto',
            'body': 'Se ha agregado un nuevo gasto de \$${amount.toStringAsFixed(2)}: $description',
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
