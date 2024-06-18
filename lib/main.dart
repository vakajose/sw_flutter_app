import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

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

class StudentIdProvider extends InheritedWidget {
  final int studentId;

  const StudentIdProvider({
    Key? key,
    required this.studentId,
    required Widget child,
  }) : super(key: key, child: child);

  static StudentIdProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StudentIdProvider>();
  }

  @override
  bool updateShouldNotify(StudentIdProvider oldWidget) {
    return oldWidget.studentId != studentId;
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
  String? _errorMessage;

  Future<int?> _authenticate(String username, String password) async {
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
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
          'x-requested-with': 'XMLHttpRequest'
        },
      );
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          return responseBody['alumno'][0]['id']; // Return student ID
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error during authentication: $e');
      return null;
    }
  }

  void _navigateToUserPage(int studentId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StudentIdProvider(
          studentId: studentId,
          child: const UserPage(),
        ),
      ),
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
              Visibility(
                visible: _errorMessage != null,
                child: Text(
                  _errorMessage ?? '',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
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
                  int? studentId = await _authenticate(username, password);
                  if (studentId != null) {
                    _navigateToUserPage(studentId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid username or password'),
                      ),
                    );
                    setState(() {
                      _errorMessage = 'Invalid username or password';
                    });
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
    final studentId = StudentIdProvider.of(context)?.studentId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            calendar(),
            const SizedBox(height: 20),
            const Text('Welcome to the User Page! :o'),
            const SizedBox(height: 10),
            if (studentId != null)
              Text('Student ID: $studentId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (studentId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionnairePage(studentId: studentId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student ID not found. Please log in again.'),
                    ),
                  );
                }
              },
              child: const Text('AI TUTORING'),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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

// --- GET questionaire
class QuestionnairePage extends StatefulWidget {
  final int studentId;

  const QuestionnairePage({super.key, required this.studentId});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class Questionnaire {
  final List<SubjectAssessment> questionnaire;
  final String explanation;
  final String id;

  Questionnaire(
      {required this.questionnaire,
      required this.explanation,
      required this.id});

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      questionnaire: (json['cuestionario'] as List)
          .map((item) => SubjectAssessment.fromJson(item))
          .toList(),
      explanation: json['explicacion'],
      id: json['id'],
    );
  }
}

class SubjectAssessment {
  final List<BaseQuestion> assessment;
  final String subject;
  final double average;

  SubjectAssessment(
      {required this.assessment, required this.subject, required this.average});

  factory SubjectAssessment.fromJson(Map<String, dynamic> json) {
    return SubjectAssessment(
      assessment: (json['evaluacion'] as List).map((item) {
        if (item.containsKey('respuesta') && item.containsKey('calificacion')) {
          return Question2.fromJson(item);
        } else {
          return Question.fromJson(item);
        }
      }).toList(),
      subject: json['materia'],
      average: json['promedio'].toDouble(),
    );
  }
}

abstract class BaseQuestion {
  String get question;
}

class Question implements BaseQuestion {
  final String question;

  Question({required this.question});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['pregunta'],
    );
  }
}

// QUESTION 2ND RESPONSE
class Question2 implements BaseQuestion {
  final String question;
  final String answer;
  final String grade;

  Question2({
    required this.question,
    required this.answer,
    required this.grade,
  });

  factory Question2.fromJson(Map<String, dynamic> json) {
    return Question2(
      question: json['pregunta'] ?? '',
      answer: json['respuesta'] ?? '',
      grade: json['calificacion'] ?? '',
    );
  }
}

Future<Questionnaire> fetchQuestionnaire(int studentId) async {
  final response = await http.get(
    Uri.parse(
        'http://vakajose.online:5000/api/init_recomendaciones/$studentId'),
  );
  if (response.statusCode == 200) {
    return Questionnaire.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load questionnaire');
  }
}
// --- END GET questionaire

// ---Evaluation
class EvaluationResponse {
  final Recommendations recommendations;
  final String status;
  EvaluationResponse({required this.recommendations, required this.status});
  factory EvaluationResponse.fromJson(Map<String, dynamic> json) {
    return EvaluationResponse(
      recommendations: Recommendations.fromJson(json['recomendaciones']),
      status: json['status'],
    );
  }
}

class Recommendations {
  final List<SubjectAssessment> questionnaire;
  final String explanation;
  final String recommendations; // Added for the markdown recommendations
  Recommendations({
    required this.questionnaire,
    required this.explanation,
    required this.recommendations, // Added this field
  });
  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      questionnaire: (json['cuestionario'] as List)
          .map((item) => SubjectAssessment.fromJson(item))
          .toList(),
      explanation: json['explicacion'],
      recommendations: json['recomendaciones'], // Parse the recommendations
    );
  }
}

Future<EvaluationResponse> sendEvaluation(
    int studentId, Map<String, dynamic> answers) async {
  try {
    final response = await http.post(
      Uri.parse('http://vakajose.online:5000/api/evaluaciones'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'alumno_id': studentId,
        'respuestas': answers,
      }),
    );

    if (response.statusCode == 200) {
      return EvaluationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to send evaluation: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to send evaluation: $e');
  }
}
// ---END Evaluation

class _QuestionnairePageState extends State<QuestionnairePage> {
  late Future<Questionnaire> _questionnaireFuture;
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _controllers;
  bool _isLoading = false; // Add a loading state

  @override
  void initState() {
    super.initState();
    _questionnaireFuture = fetchQuestionnaire(widget.studentId);
    _controllers = [];
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
              int totalQuestions = questionnaire.questionnaire
                  .fold(0, (sum, item) => sum + item.assessment.length);
              if (_controllers.isEmpty) {
                _controllers = List.generate(
                  totalQuestions,
                  (index) => TextEditingController(),
                );
              }
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
                            controller: _controllers[
                                questionIndex++], // Use and increment the overall question index
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
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true; // Show loading indicator
                                  });
                                  Map<String, dynamic> answersPayload =
                                      _formatAnswersForAPI(
                                          widget.studentId,
                                          _controllers,
                                          snapshot.data!.questionnaire,
                                          questionnaire);
                                  sendEvaluation(
                                          widget.studentId, answersPayload)
                                      .then((evaluationResponse) {
                                    setState(() {
                                      _isLoading =
                                          false; // Hide loading indicator
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResultsPage(
                                            evaluationResponse:
                                                evaluationResponse),
                                      ),
                                    );
                                  }).catchError((error) {
                                    setState(() {
                                      _isLoading =
                                          false; // Hide loading indicator
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error sending evaluation: $error'),
                                      ),
                                    );
                                  });
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

  Map<String, dynamic> _formatAnswersForAPI(
    int studentId,
    List<TextEditingController> controllers,
    List<SubjectAssessment> questionnaireData,
    Questionnaire questionnaire,
  ) {
    int questionIndex = 0;
    List<Map<String, dynamic>> formattedQuestionnaire = [];
    for (var subjectAssessment in questionnaireData) {
      List<Map<String, dynamic>> formattedAssessment = [];
      for (var question in subjectAssessment.assessment) {
        formattedAssessment.add({
          'pregunta': question.question,
          'respuesta': controllers[questionIndex].text,
        });
        questionIndex++;
      }
      formattedQuestionnaire.add({
        'materia': subjectAssessment.subject,
        'promedio': subjectAssessment.average,
        'evaluacion': formattedAssessment,
      });
    }
    return {
      'cuestionario': formattedQuestionnaire,
      'explicacion': questionnaire.explanation ?? '',
      'id': questionnaire.id ?? '',
    };
  }
}

class ResultsPage extends StatelessWidget {
  final EvaluationResponse evaluationResponse;
  const ResultsPage({super.key, required this.evaluationResponse});

  @override
  Widget build(BuildContext context) {
    final studentId = StudentIdProvider.of(context)?.studentId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentIdProvider(
                    studentId: studentId!,
                    child: const UserPage(),
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var subjectAssessment in evaluationResponse.recommendations.questionnaire)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subject: ${subjectAssessment.subject}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (var assessment in subjectAssessment.assessment)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Question: ${(assessment as Question2).question}'),
                          Text('Answer: ${(assessment as Question2).answer ?? ''}'),
                          Text('Grade: ${(assessment as Question2).grade ?? ''}'),
                          const SizedBox(height: 16),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              Text('Explanation:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              MarkdownBody(data: evaluationResponse.recommendations.explanation),
              const SizedBox(height: 16),
              Text('Recommendations:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              MarkdownBody(data: evaluationResponse.recommendations.recommendations),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Return to Questionnaire'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const UserPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Return to User Page'),
              ),
            ),
          ],
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
        title:
            Text('Tasks for ${DateFormat('MM/dd/yyyy').format(selectedDate)}'),
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
                        Text(
                            'Date: ${DateFormat('MM/dd/yyyy').format(event.date)}'),
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
