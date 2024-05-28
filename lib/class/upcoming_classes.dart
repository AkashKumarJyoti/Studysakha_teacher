import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingClasses extends StatefulWidget {
  bool refresh;
  UpcomingClasses({Key? key, required this.refresh}) : super(key: key);

  @override
  _UpcomingClassesState createState() => _UpcomingClassesState();
}

class _UpcomingClassesState extends State<UpcomingClasses> {
  var docId = FirebaseAuth.instance.currentUser?.uid;
  var photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
  var name = FirebaseAuth.instance.currentUser?.displayName;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 383.25,
      height: 120.43,
      margin: const EdgeInsets.only(top: 33.46, left: 15.1),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').doc(docId).collection('upcoming_classes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No upcoming classes"));
          }

          List<DocumentSnapshot> upcomingClasses = [];
          for (var doc in snapshot.data!.docs) {
            DateTime classTime = (doc['time'] as Timestamp).toDate();
            if (classTime.isAfter(DateTime.now())) {
              upcomingClasses.add(doc);
            }
          }

          return upcomingClasses.isEmpty ? const Center(child: Text("No Upcoming Classes")) : ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: upcomingClasses.length,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                height: 140,
                margin: const EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 8.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: ClipOval(
                        child: Image.network(photoUrl!,
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Topic : ",
                          style: TextStyle(
                            color: const Color(0xFF000000).withOpacity(0.7),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${upcomingClasses[index]['topic']}",
                            style: const TextStyle(color: Color(0xFF000000)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //     Text(
                    //       "From : ",
                    //       style: TextStyle(
                    //         color: const Color(0xFF000000).withOpacity(0.7),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: Text(
                    //         "${upcomingClasses[index]['name']}",
                    //         style: const TextStyle(color: Color(0xFF000000)),
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 5),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFF3D73EB).withOpacity(0.4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(_formatTimestamp(upcomingClasses[index]['time'])),
                        )
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

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    String formattedTime = DateFormat.jm().format(dateTime);
    String formattedDate = DateFormat('dd MMM').format(dateTime);

    return '$formattedTime, $formattedDate';
  }

}
