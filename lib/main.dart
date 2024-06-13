import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ScheEdu());
}

class ScheEdu extends StatelessWidget {
  const ScheEdu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: content(),
      ),
    );
  }

  Widget content() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: DateTime.now(),
        )
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<bool> _authenticate(String username, String password) async {
    try {
      var reqBody = {
        "ci": username,
        "apellido": password,
      };
      final response = await http.post(
        Uri.parse('http://vakajose.online:5000/api/login'),
        body: jsonEncode(reqBody),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  void _navigateToUserPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String username = _usernameController.text;
                  String password = _passwordController.text;
                  if (await _authenticate(username, password)) {
                    _navigateToUserPage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid username or password'),
                      ),
                    );
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: Center(
        child: Column(
          children: [
            calendar(),
            const Text('Welcome to the User Page! :o'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int studentId = 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionnairePage(studentId: studentId),
                  ),
                );
              },
              child: const Text('AI TUTORING'),
            ),
          ],
        ),
      ),
    );
  }

  Widget calendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: DateTime.now(),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskPage(selectedDate: _selectedDay),
          ),
        );
      },
    );
  }
}

class QuestionnairePage extends StatefulWidget {
  final int studentId;

  const QuestionnairePage({super.key, required this.studentId});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class Questionnaire {
  final List<SubjectAssessment> questionnaire;
  final String explanation;

  Questionnaire({required this.questionnaire, required this.explanation});

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      questionnaire: (json['cuestionario'] as List)
          .map((item) => SubjectAssessment.fromJson(item))
          .toList(),
      explanation: json['explicacion'],
    );
  }
}

class SubjectAssessment {
  final List<Question> assessment;
  final String subject;
  final double average;

  SubjectAssessment({required this.assessment, required this.subject, required this.average});

  factory SubjectAssessment.fromJson(Map<String, dynamic> json) {
    return SubjectAssessment(
      assessment: (json['evaluacion'] as List)
          .map((item) => Question.fromJson(item))
          .toList(),
      subject: json['materia'],
      average: json['promedio'].toDouble(),
    );
  }
}

class Question {
  final String question;

  Question({required this.question});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['pregunta'],
    );
  }
}

Future<Questionnaire> fetchQuestionnaire(int studentId) async {
  final response = await http.get(
    Uri.parse('http://vakajose.online:5000/api/init_recomendaciones/$studentId'),
  );
  if (response.statusCode == 200) {
    return Questionnaire.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load questionnaire');
  }
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  late Future<Questionnaire> _questionnaireFuture;
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _questionnaireFuture = fetchQuestionnaire(widget.studentId);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('AI Tutoring Questionnaire'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<Questionnaire>(
        future: _questionnaireFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final questionnaire = snapshot.data!;
            // Correctly calculate the total number of questions
            int totalQuestions = questionnaire.questionnaire.fold(
                0, (sum, item) => sum + item.assessment.length);
            _controllers = List.generate(
              totalQuestions,
              (index) => TextEditingController(),
            );
            int questionIndex = 0; // Keep track of the overall question index
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var subjectAssessment in questionnaire.questionnaire)
                      for (var question in subjectAssessment.assessment) ...[
                        Text(question.question),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _controllers[questionIndex++], // Use and increment the overall question index
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an answer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Process the answers (e.g., send to an AI model)
                          List<String> answers = _controllers.map((c) => c.text).toList();
                          // ... Your logic to handle the answers ...
                        }
                      },
                      child: const Text('Evaluate'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No questionnaire found.'));
          }
        },
      ),
    ),
  );
}
  }

class Event {
  final String title;
  final String description;
  final DateTime date;

  Event({
    required this.title,
    required this.description,
    required this.date,
  });
}

class TaskPage extends StatelessWidget {
  final DateTime selectedDate;

  const TaskPage({super.key, required this.selectedDate});

  Future<List<Event>> _fetchEvents(DateTime date) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Event(
        title: 'Meeting with Professor',
        description: 'Discuss research project progress.',
        date: DateTime(date.year, date.month, date.day, 10, 0),
      ),
      Event(
        title: 'Study Group Session',
        description: 'Review chapter 5 for upcoming exam.',
        date: DateTime(date.year, date.month, date.day, 15, 30),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for ${DateFormat('MM/dd/yyyy').format(selectedDate)}'),
      ),
      body: FutureBuilder<List<Event>>(
        future: _fetchEvents(selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.description),
                        Text('Date: ${DateFormat('MM/dd/yyyy').format(event.date)}'),
                        Text('Hour: ${DateFormat('HH:mm').format(event.date)}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
