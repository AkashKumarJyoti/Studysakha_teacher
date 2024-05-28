import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studysakha_teacher/calling/call_start.dart';

class LiveClasses extends StatefulWidget {
  bool refresh;
  LiveClasses({Key? key, required this.refresh}) : super(key: key);

  @override
  _LiveClassesState createState() => _LiveClassesState();
}

class _LiveClassesState extends State<LiveClasses> {
  var docId = FirebaseAuth.instance.currentUser?.uid;
  var photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
  var name = FirebaseAuth.instance.currentUser?.displayName;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 383.25,
      height: 120.43,
      margin: const EdgeInsets.only(top: 10, left: 15.1),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').doc(docId).collection('upcoming_classes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Live classes"));
          }

          List<DocumentSnapshot> liveClasses = [];

          for (var doc in snapshot.data!.docs) {
            DateTime classTime = (doc['time'] as Timestamp).toDate();
            if (classTime.isBefore(DateTime.now()) || classTime == DateTime.now()) {
              liveClasses.add(doc);
            }
          }

          return liveClasses.isEmpty ? const Center(child: Text("No Live Class")) : ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: liveClasses.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(top: 10.0, right: 15),
                width: 331,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3D73EB), Color(0xFFDE8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.134, 0.866],
                  ),
                  border: Border.all(
                    color: const Color(0xFF2664F599),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          '$photoUrl',
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Topic: ${_truncateText(liveClasses[index]['topic'])}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: ()
                          {
                            FirebaseFirestore.instance.collection('teachers').doc(docId).collection('upcoming_classes').doc(liveClasses[index].id).delete();
                            FirebaseFirestore.instance.collection('live_room').doc(liveClasses[index].id).delete();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Text("End Class",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,),
                            ),
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 70.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CallStart(docId: liveClasses[index].id, roomUrl: liveClasses[index]['roomUrlSpeaker'], roomId: liveClasses[index]['roomId'])),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              const Text(
                                'Join',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _truncateText(String text, {int maxLength = 15}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }


  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    String formattedTime = DateFormat.jm().format(dateTime);
    String formattedDate = DateFormat('dd MMM').format(dateTime);

    return '$formattedTime, $formattedDate';
  }

}
