import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotifyOpenBoxScreen extends StatelessWidget {
  const NotifyOpenBoxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notify Open Box')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ApiService.fetchCoins(context);
          },
          child: Text('Fetch Coins'),
        ),
      ),
    );
  }
}

class ApiService {
  static void fetchCoins(BuildContext context) async {
    final url = Uri.parse('http://your_api_url/notify-open-box');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final coins = jsonDecode(response.body);
      showNotification(context, 'Coins Fetched', 'Top ranked coins updated');
    } else {
      throw Exception('Failed to load coins');
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
