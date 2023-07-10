import 'package:flutter/material.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Workout'),
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: exerciseList.length,
            itemBuilder: (context, index) {
              return ExerciseCard();
            },
          ),
        ),
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Exercise Name'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Repetitions'),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy exercise list for testing
final List<String> exerciseList = [
  'Exercise 1',
  'Exercise 2',
  'Exercise 3',
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Active Workout Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ActiveWorkoutScreen(),
    );
  }
}
