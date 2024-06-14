import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String serverKey = 'TU_SERVER_KEY_AQUÍ'; // Aquí pones la Server Key que obtuviste de Firebase
  final String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  Future<void> sendNotification(String title, String body, String token) async {
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
            'title': title,
            'body': body,
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
