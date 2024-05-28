import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:studysakha_teacher/class/room_create.dart';
import 'management_token.dart';

class ClassCreate extends StatefulWidget {
  const ClassCreate({Key? key}) : super(key: key);

  @override
  State<ClassCreate> createState() => _ClassCreateState();
}

class _ClassCreateState extends State<ClassCreate> {
  final _topicKey = GlobalKey<FormState>();
  TextEditingController topicController = TextEditingController();
  Timestamp selectedTime = Timestamp.now();
  bool flag = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Create Room"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Form(
              key: _topicKey,
              child: SizedBox(
                child: TextFormField(
                  maxLines: 1,
                  controller: topicController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your topic';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter your today topic',
                    hintText: 'Learn English',
                    prefixIcon: const Icon(Icons.book_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                DatePicker.showTimePicker(
                  context,
                  showTitleActions: true,
                  onConfirm: (time) {
                    setState(() {
                      flag = true;
                      selectedTime = Timestamp.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);
                    });
                    print(selectedTime.toDate()); // You can print the selected time as a DateTime object
                  },
                  currentTime: DateTime.now(),
                  locale: LocaleType.en,
                );
              },
              child: const Text(
                'Select time of the class',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                if (_validateForm()) {
                  addRoomToFirebase(context);
                }
                debugPrint("Hello");
              },
              child: const Text("Add Room"),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    return _topicKey.currentState!.validate();
  }

  Future<void> addRoomToFirebase(BuildContext context) async {
    if (flag == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the time'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        var docId = FirebaseAuth.instance.currentUser?.uid;
        var currentUser = FirebaseAuth.instance.currentUser;
        CollectionReference rooms = firestore.collection('live_room');
        String token = generateToken();
        HMSSDK hmssdk = HMSSDK();
        await hmssdk.build();
        Variable? roomDetails = await RoomService.createRoom(token, hmssdk);

        DocumentReference documentReference = await rooms.add({
          'topic': topicController.text,
          'time': selectedTime,
          'name': currentUser?.displayName,
          'photoUrl': currentUser?.photoURL,
          'roomUrlListener': roomDetails?.roomUrlListener,
          'screenShare': false,
          'quizTime': false
        });
        String documentId = documentReference.id;
        DocumentReference pushRoom = firestore.collection('teachers').doc(docId).collection('upcoming_classes').doc(documentId);
        pushRoom.set({
          'time': selectedTime,
          'topic': topicController.text,
          'roomUrlSpeaker': roomDetails?.roomUrlSpeaker,
          'roomId': roomDetails?.roomId,
        });
        topicController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room added successfully'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );

        debugPrint("Room added to Firebase");
      } catch (e) {
        debugPrint("Error adding room to Firebase: $e");
      }
    }
  }
}
