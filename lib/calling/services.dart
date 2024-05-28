import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../class/management_token.dart';

class CallService
{
  static Future<void> screenShareVar(String docId, bool isScreenShare) async {
    FirebaseFirestore.instance.collection('live_room').doc(docId).update({
      'screenShare': isScreenShare
    });
  }

  static leaveRoom(String roomId) async {
    String token = generateToken();
    String apiUrl = 'https://api.100ms.live/v2/rooms/$roomId';
    Map<String, dynamic> requestBody = {
      "enabled": false,
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
    } catch (error) {
      print('Error: $error');
    }
  }
}