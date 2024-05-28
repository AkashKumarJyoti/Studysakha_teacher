import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuizCreate extends StatefulWidget {
  const QuizCreate({Key? key}) : super(key: key);

  @override
  State<QuizCreate> createState() => _QuizCreateState();
}

class _QuizCreateState extends State<QuizCreate> {

  final _questionKey = GlobalKey<FormState>();
  final _option1Key = GlobalKey<FormState>();
  final _option2Key = GlobalKey<FormState>();
  final _option3Key = GlobalKey<FormState>();
  final _option4Key = GlobalKey<FormState>();
  final _answerKey = GlobalKey<FormState>();

  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();
  TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: const Text("Create Quiz"),
            centerTitle: true,
            elevation: 0
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Form(
                key: _questionKey,
                child: SizedBox(
                  child: TextFormField(
                    maxLines: 1,
                    controller: questionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your question';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter your Question',
                      hintText: 'What is the capital of France?',
                      prefixIcon: const Icon(Icons.question_answer),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Text("1."),
                    ),
                    Expanded(
                      child: Form(
                        key: _option1Key,
                        child: TextFormField(
                          controller: option1Controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter option';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Enter first option',
                            hintText: 'Delhi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Text("2."),
                    ),
                    Expanded(
                      child: Form(
                        key: _option2Key,
                        child: TextFormField(
                          controller: option2Controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter option';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Enter second option',
                            hintText: 'Paris',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Text("3."),
                    ),
                    Expanded(
                      child: Form(
                        key: _option3Key,
                        child: TextFormField(
                          controller: option3Controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter option';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Enter third option',
                            hintText: 'Kabul',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Text("4."),
                    ),
                    Expanded(
                      child: Form(
                        key: _option4Key,
                        child: TextFormField(
                          controller: option4Controller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter option';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Enter fourth option',
                            hintText: 'Canberra',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 50,
                child: Form(
                  key: _answerKey,
                  child: TextFormField(
                    controller: answerController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter answer';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter correct option',
                      hintText: '2',
                      prefixIcon: const Icon(Icons.check),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () {
                    if (_validateForm()) {
                      addQuizToFirebase(context);
                    }
                    debugPrint("Hello");
                  }, child: const Text("Add Quiz"))
            ],
          ),
        )
    );
  }

  bool _validateForm() {
    return _questionKey.currentState!.validate() &&
        _option1Key.currentState!.validate() &&
        _option2Key.currentState!.validate() &&
        _option3Key.currentState!.validate() &&
        _option4Key.currentState!.validate() &&
        _answerKey.currentState!.validate();
  }

  void addQuizToFirebase(BuildContext context) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var docId = FirebaseAuth.instance.currentUser?.uid;

      CollectionReference quizzes = firestore.collection('teachers')
          .doc(docId)
          .collection('quiz');

      quizzes.add({
        'question': questionController.text,
        'option1': option1Controller.text,
        'option2': option2Controller.text,
        'option3': option3Controller.text,
        'option4': option4Controller.text,
        'correctOption': int.parse(answerController.text),
      });

      questionController.clear();
      option1Controller.clear();
      option2Controller.clear();
      option3Controller.clear();
      option4Controller.clear();
      answerController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quiz added successfully'),
          duration: Duration(seconds: 3),
        ),
      );

      debugPrint("Quiz added to Firebase");
    } catch (e) {
      debugPrint("Error adding quiz to Firebase: $e");
    }
  }
}
