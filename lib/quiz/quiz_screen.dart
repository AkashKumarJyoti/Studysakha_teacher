import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studysakha_teacher/quiz/quiz_create.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Stream<QuerySnapshot> quizStream;
  late List<DocumentSnapshot> quizzes;
  var uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // This will make the status bar transparent
    ));
    quizStream = FirebaseFirestore.instance
        .collection('teachers')
        .doc(uid)
        .collection('quiz')
        .snapshots();
    quizzes = [];
  }

  int currentIndex = 0;

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
            child: const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 15.0),
                  Text(
                    "Quiz",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                        color: Color(0xFFFFFFFF)),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const QuizCreate()));
              },
              child: const Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.add_circle, color: Colors.white),
                  ),
                  Text("Create Quiz for students",
                      style: TextStyle(
                        color: Colors.white,
                      ))
                ],
              )),
        ),
        const SizedBox(height: 25),
        const Text("Your Quizzes",
            style: TextStyle(color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500
            )),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: quizStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No quizzes available.'));
            } else {
              quizzes = snapshot.data!.docs;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q. ${quizzes[currentIndex]['question']}',
                        style: const TextStyle(
                            color: Colors.black, fontSize: 16),
                      ),
                      Text("A. ${quizzes[currentIndex]['option1']}", style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14
                      )),
                      Text("B. ${quizzes[currentIndex]['option2']}", style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14
                      )),
                      Text("C. ${quizzes[currentIndex]['option3']}", style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14
                      )),
                      Text("D. ${quizzes[currentIndex]['option4']}", style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14
                      ))
                    ],
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            currentIndex != 0 ? ElevatedButton(
              onPressed: () {
                setState(() {
                  currentIndex =
                      (currentIndex - 1).clamp(0, quizzes.length - 1);
                });
              },
              child: const Text('Previous'),
            ) : Container(),
            currentIndex != quizzes.length - 1 ? ElevatedButton(
              onPressed: () {
                setState(() {
                  currentIndex =
                      (currentIndex + 1).clamp(0, quizzes.length - 1);
                });
              },
              child: const Text('Next'),
            ) : Container(),
          ],
        ),
      ],
    ));
  }
}
