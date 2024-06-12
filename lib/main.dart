import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

void main() {
  runApp(const ScheEdu());
}

class ScheEdu extends StatelessWidget {
  const ScheEdu({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // *** home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Replace with your authentication logic (e.g., Firebase)
  bool _authenticate(String username, String password) {
    // Simulate successful login for demo purposes
    return username == "test" && password == "test123";
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
                obscureText: true, // Hide password
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String username = _usernameController.text;
                  String password = _passwordController.text;
                  if (_authenticate(username, password)) {
                    _navigateToUserPage();
                  } else {
                    // Show error message
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

// Placeholder UserPage (replace with your actual user page)
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
        // Navigate to the TaskPage with the selected date
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

  // Placeholder for fetching events - replace with your actual logic
  Future<List<Event>> _fetchEvents(DateTime date) async {
    // Simulate fetching events - replace with your actual data source
    await Future.delayed(const Duration(seconds: 1));
    return [
      Event(
        title: 'Meeting with Professor',
        description: 'Discuss research project progress.',
        date: DateTime(date.year, date.month, date.day, 10, 0), // 10:00 AM
      ),
      Event(
        title: 'Study Group Session',
        description: 'Review chapter 5 for upcoming exam.',
        date: DateTime(date.year, date.month, date.day, 15, 30), // 3:30 PM
      ),
    ];
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for ${selectedDate.toLocal()}'), // Display date
      ),
      body: Center(
        // Replace this with your actual task fetching and display logic
        child: Text('Display tasks for ${selectedDate.toLocal()} here'), 
      ),
    );
  }
  */
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

void getOdooData() async {
  // Odoo server connection details (replace with your actual values)
  const url = 'http://192.168.3.69:8085';
  const db = 'odooExamen';
  const username = 'usuario_api';
  const password = '5362fc5061dd406b74b55be9dd640faa5cc45084';

  // Create an OdooClient instance
  final odoo = OdooClient(
    url
  );

  try {
    // Authenticate with Odoo server
    final session = await odoo.authenticate(db, username, password);
    print(session);
    print('Authenticated');
    //await odoo.login(username: username, password: password);

    // Call the 'search_read' method to retrieve data
    final result = await odoo.callKw(
      {
        'model': "colegios.alumno",
        'method': "search_read",
        'args': [],
      }
    );

    // Access the retrieved data (list of maps)
    final alumnos = result.result;

    // Print or process the retrieved data
    for (var alumno in alumnos) {
      print(alumno); // Example: {'id': 123, 'name': 'John Doe', ...}
      // Access specific fields using alumno['field_name']
    }
  } on OdooException catch (e) {
    print("Odoo error: ${e.message}");
  } catch (e) {
    print("Error: ${e.toString()}");
  } finally {
    // Close the Odoo connection (optional)
    odoo.close();
  }
}