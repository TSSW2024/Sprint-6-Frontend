import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotifyCheckCoinsScreen extends StatelessWidget {
  const NotifyCheckCoinsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notify Check Coins')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ApiService.fetchMessages(context);
          },
          child: Text('Fetch Messages'),
        ),
      ),
    );
  }
}

class ApiService {
  static void fetchMessages(BuildContext context) async {
    final url = Uri.parse('http://your_api_url/notify-check-coins');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final messages = jsonDecode(response.body);
      showNotification(context, 'Messages Fetched', 'You have new messages');
    } else {
      throw Exception('Failed to load messages');
    }
  }

  static void showNotification(BuildContext context, String title, String body) {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
