import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:studysakha_teacher/class/live_classes.dart';
import 'package:studysakha_teacher/class/room_create_data.dart';
import 'package:studysakha_teacher/class/upcoming_classes.dart';

class ClassInfo extends StatefulWidget {
  const ClassInfo({Key? key}) : super(key: key);

  @override
  State<ClassInfo> createState() => _ClassInfoState();
}

class _ClassInfoState extends State<ClassInfo> {
  bool refresh = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
      Colors.transparent, // This will make the status bar transparent
    ));
  }
  var docId = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF08FFB8), Color(0xFF5799F7)]),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 15.0),
                    InkWell(
                      onTap: () async
                      {
                        await GoogleSignIn().disconnect();
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text(
                        "Class",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 26,
                            color: Color(0xFFFFFFFF)),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: ()
                        {
                          setState(() {
                            refresh = !refresh;
                          });
                        },
                        child: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    )

                  ],
                ),
              )),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ClassCreate()));
                },
                child: const Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(Icons.add_circle, color: Colors.white),
                    ),
                    Text("Create Room",
                        style: TextStyle(
                          color: Colors.white,
                        ))
                  ],
                )),
          ),
          const SizedBox(height: 20),
          const Text("Your Live Class", style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16
          )),
          LiveClasses(refresh: refresh),
          const SizedBox(height: 15),
          const SizedBox(height: 20),
          const Text("Your Upcoming Classes", style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16
          )),
          const SizedBox(height: 15),
          UpcomingClasses(refresh: refresh)
      // StreamBuilder<QuerySnapshot>(
      //   stream: FirebaseFirestore.instance.collection('teachers').doc(docId).collection('upcoming_classes').snapshots(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const CircularProgressIndicator();
      //     }
      //
      //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      //       return const Text("No upcoming classes");
      //     }
      //
      //     return Column(
      //       children: [
      //         for (var doc in snapshot.data!.docs)
      //           ListTile(
      //             title: Text(doc['topic'] ?? ''),
      //             subtitle: Text(_formatTimestamp(doc['time'])),
      //             trailing: ElevatedButton(
      //               onPressed: () {
      //                 debugPrint(doc['roomUrl']);
      //               },
      //               child: const Text("Join Class"),
      //             ),
      //           ),
      //       ],
      //     );
      //   },
      // ),
        ],
      )
    );
  }
  String _formatTimestamp(dynamic time) {
    if (time is Timestamp) {
      DateTime dateTime = time.toDate();
      return DateFormat('MMM d, yyyy hh:mm a').format(dateTime);
    } else if (time is String) {
      return time;
    } else {
      throw Exception('Unexpected type for time field');
    }
  }
}
