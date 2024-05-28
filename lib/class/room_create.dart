import 'dart:convert';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:http/http.dart' as http;

class RoomService {
  static Future<Variable?> createRoom(String token, HMSSDK hmssdk) async {
    String apiUrl = 'https://api.100ms.live/v2/rooms?template_id=6546890745b44708fd4131f9&template=AR-quiet-sea-788903';
    Map<String, dynamic> requestBody = {
      "description": "This is a sample description for the room",
      "template_id": "6546890745b44708fd4131f9",
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> roomInfo = json.decode(response.body);

        String roomId = roomInfo['id'];
        String rCodeListener = await roomCodeListener(roomId, token);
        String rCodeSpeaker = await roomCodeSpeaker(roomId, token);

        String roomUrlListener = await hmssdk.getAuthTokenByRoomCode(roomCode: rCodeListener);
        String roomUrlSpeaker = await hmssdk.getAuthTokenByRoomCode(roomCode: rCodeSpeaker);
        Variable roomDetails = Variable(roomId: roomId, roomUrlListener: roomUrlListener, roomUrlSpeaker: roomUrlSpeaker);
        return roomDetails;
      } else {
        print('Failed to get room info. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    return null;
  }

  static Future<String> roomCodeListener(String roomId, String token) async {
    String roomCodeUrl = 'https://api.100ms.live/v2/room-codes/room/$roomId/role/listener';

    try {
      final response = await http.post(
        Uri.parse(roomCodeUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> roomInfo = json.decode(response.body);
        String roomCode = roomInfo['code'];
        return roomCode;
      } else {
        print('Failed to generate Room Code. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to generate Room Code');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('An error occurred while generating Room Code');
    }
  }

  static Future<String> roomCodeSpeaker(String roomId, String token) async {
    String roomCodeUrl = 'https://api.100ms.live/v2/room-codes/room/$roomId/role/speaker';

    try {
      final response = await http.post(
        Uri.parse(roomCodeUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> roomInfo = json.decode(response.body);
        String roomCode = roomInfo['code'];
        return roomCode;
      } else {
        // This will handle unsuccessful request
        print('Failed to generate Room Code. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to generate Room Code');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('An error occurred while generating Room Code');
    }
  }
}

class Variable
{
  String roomId;
   String roomUrlListener;
   String roomUrlSpeaker;

  Variable({required this.roomId, required this.roomUrlListener, required this.roomUrlSpeaker});
}