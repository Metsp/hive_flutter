import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../utils/colors.dart';

class EmptyWorkoutScreen extends StatefulWidget {
  const EmptyWorkoutScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmptyWorkoutScreenState createState() => _EmptyWorkoutScreenState();
}

class _EmptyWorkoutScreenState extends State<EmptyWorkoutScreen> {
  TextEditingController workoutNotesController = TextEditingController();
  List<Exercise> exercises = [];
  String tempWorkoutName = "";
  String workoutName = "Workout Name";
  String workoutNote = "";
  late DateTime workoutStartTime;
  String workoutDuration = '0:00:00';

  void calculateTimeDifference() {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(workoutStartTime);
    final formattedDifference =
        DateFormat('H:mm:ss').format(DateTime(0).add(difference));
    setState(() {
      workoutDuration = formattedDifference;
    });
  }

  @override
  void initState() {
    super.initState();
    workoutStartTime = DateTime.now();
  }

  @override
  void dispose() {
    workoutNotesController.dispose();
    super.dispose();
  }

  TimerWidget timerWidget = TimerWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showCancelDialog();
          },
          color: hiveBlack,
          icon: const Icon(
            Icons.close_rounded,
            size: 25,
          ),
        ),
        backgroundColor: hiveWhite,
        centerTitle: false,
        elevation: 0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 12),
            child: ElevatedButton(
              onPressed: () {
                // Show confirmation Dialog
                showFinishDialog();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: hiveLightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(
                'Finish',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    workoutName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 0.0,
                  ),
                  child: IconButton(
                    onPressed: () {
                      _showTextInputDialog(context);
                    },
                    color: hiveBlack,
                    icon: const Icon(
                      Icons.edit,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                timerWidget,
              ],
            ),
            TextField(
              controller: workoutNotesController,
              decoration: const InputDecoration(
                hintText: 'Notes...',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(202, 202, 202, 1),
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                  color: hiveBlack, fontWeight: FontWeight.bold),
              onChanged: (value) {
                setState(() {
                  workoutNote = value;
                });
              },
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  //Rest of the elements
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return ExerciseCard(
                        key: UniqueKey(),
                        exercise: exercises[index],
                        onDelete: () {
                          showDeleteConfirmationDialog(index);
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextButton(
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        setState(
                          () {
                            exercises.add(
                              Exercise(
                                id: const Uuid().v1(),
                                name: '',
                                sets: -1,
                                reps: -1,
                                weight: -1.0,
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: hiveLightBlue,
                          border: Border.all(color: hiveLightBlue),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        height: 40,
                        child: const Text(
                          "Add Exercise",
                          style: TextStyle(
                              color: hiveBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      showCancelDialog();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: hiveLightRed,
                        border: Border.all(color: hiveLightRed),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      height: 40,
                      child: const Text(
                        "Cancel Workout",
                        style: TextStyle(
                            color: hiveRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================================================================
  // Dialog Boxes
  // =========================================================================================================================

  void showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          contentPadding:
              const EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
          contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          backgroundColor: hiveWhite,
          content: const Text(
            'Delete this exercise?',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: hiveBlack, fontSize: 20),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent, // Background color
                ),
                child: const Text(
                  'Cancel',
                  style:
                      TextStyle(color: hiveBlack, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: hiveYellow, // Background color
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: hiveBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    exercises.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void showFinishDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        contentPadding:
            const EdgeInsets.only(top: 20, bottom: 5, left: 23, right: 23),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: hiveWhite,
        title: const Text(
          'End the workout?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Ready for that protein shake?',
          style: TextStyle(
              fontWeight: FontWeight.w400, color: hiveBlack, fontSize: 17),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent, // Background color
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: hiveBlack, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(_).pop();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: hiveYellow, // Background color
              ),
              child: const Text(
                'Im Done!',
                style: TextStyle(
                  color: hiveBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                calculateTimeDifference();
                saveWorkoutToFirestore(exercises);
                showSnackBar('Workout Complete!', context);
                Navigator.of(_).pop();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        contentPadding:
            const EdgeInsets.only(top: 20, bottom: 5, left: 22, right: 22),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: hiveWhite,
        title: const Text(
          'Cancel this workout?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure? Don\'t start slacking!',
          style: TextStyle(
              fontWeight: FontWeight.w400, color: hiveBlack, fontSize: 17),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent, // Background color
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: hiveBlack, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(_).pop();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: hiveYellow, // Background color
              ),
              child: const Text(
                'End it!',
                style: TextStyle(
                  color: hiveBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(_).pop();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTextInputDialog(BuildContext context) async {
    TextEditingController _textFieldController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          contentPadding:
              const EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
          contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          backgroundColor: hiveWhite,
          content: TextField(
            controller: _textFieldController,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: 'Enter Workout Name',
              floatingLabelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent, // Background color
                ),
                child: const Text(
                  'Cancel',
                  style:
                      TextStyle(color: hiveBlack, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: hiveYellow, // Background color
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    color: hiveBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (_textFieldController.text.isEmpty) {
                    // Show error message if the text field is empty.
                    ScaffoldMessenger.of(context).showSnackBar(
                        showSnackBar("Please input a Workout Name", context));
                  } else {
                    // Save the text in the input box to the workoutName variable.
                    tempWorkoutName = _textFieldController.text;
                    setState(() {
                      workoutName = tempWorkoutName;
                    });
                    // Dismiss the dialog box.
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================================================================
  // Saving Exercise into firebase
  // =========================================================================================================================

  String formatExerciseToString(Exercise exercise) {
    if (exercise.name == "") {
      exercise.name = "Exercise";
    }
    if (exercise.sets == "") {
      exercise.sets = 0;
    }
    if (exercise.reps == "") {
      exercise.reps = 0;
    }
    if (exercise.weight == "") {
      exercise.weight = 0.0;
    }

    String exerciseString =
        '${exercise.name}: ${exercise.sets} Sets x ${exercise.reps} Reps';
    if (exercise.weight != null) {
      exerciseString += ' x ${exercise.weight}kg';
    }
    return exerciseString;
  }

  String combineExercisesToString(List<Exercise> exercises) {
    String combinedWorkoutString = '';
    for (Exercise exercise in exercises) {
      combinedWorkoutString += '${formatExerciseToString(exercise)}\n';
    }
    return combinedWorkoutString.trim();
  }

  void saveWorkoutToFirestore(List<Exercise> exercises) async {
    final firestore = FirebaseFirestore.instance;
    String workoutID = const Uuid().v1();

    // Small calculation used to measure total workout weight
    int totalSets = 0;
    int totalReps = 0;
    double totalWeight = 0.0;
    double combinedWeight = 0.0;

    for (Exercise exercise in exercises) {
      if (exercise.sets == -1) {
        exercise.sets = 0;
      }
      if (exercise.reps == -1) {
        exercise.reps = 0;
      }
      if (exercise.weight == -1.0) {
        exercise.weight = 0.0;
      }
      totalSets = exercise.sets!;
      totalReps = exercise.reps!;
      totalWeight = exercise.weight!;
      combinedWeight +=
          totalSets.toDouble() * totalReps.toDouble() * totalWeight;
    }

    // Saving to firebase firestore as a workout template
    await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('workouts')
        .doc(workoutID)
        .set({
      'copiedUserID': "empty",
      'userID': FirebaseAuth.instance.currentUser!.uid.toString(),
      'workoutID': workoutID,
      'workoutName': workoutName,
      'workoutNote': workoutNote,
      'workoutExercises': combineExercisesToString(exercises),
      'workoutDate': workoutStartTime,
    });

    // ignore: avoid_function_literals_in_foreach_calls
    exercises.forEach((exercise) async {
      if (exercise.name == "") {
        exercise.name = "Exercise";
      }
      if (exercise.sets == "") {
        exercise.sets = 0;
      }
      if (exercise.reps == "") {
        exercise.reps = 0;
      }
      if (exercise.weight == "") {
        exercise.weight = 0.0;
      }
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('workouts')
          .doc(workoutID)
          .collection('exercises')
          .add({
        'id': exercise.id,
        'name': exercise.name,
        'sets': exercise.sets,
        'reps': exercise.reps,
        'weight': exercise.weight,
      }).then((value) {
        // ignore: avoid_print
        print('Exercise ${exercise.id} saved successfully!');
      }).catchError((error) {
        // ignore: avoid_print
        print('Failed to save exercise ${exercise.id}: $error');
      });
    });

    // Saving workout history
    String historyID = const Uuid().v1();
    await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('workoutHistory')
        .doc(historyID)
        .set(
      {
        'historyID': historyID,
        'workoutName': workoutName,
        'workoutDuration': workoutDuration,
        'workoutDate': workoutStartTime,
        'workoutWeight': combinedWeight.toString(),
        'workoutExercises': combineExercisesToString(exercises),
      },
    );
  }
}

// =========================================================================================================================
// Exercise class used to save the workout information
// =========================================================================================================================

class Exercise {
  String id;
  String name;
  int? sets;
  int? reps;
  double? weight;

  Exercise(
      {required this.id,
      required this.name,
      required this.sets,
      required this.reps,
      required this.weight});
}

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onDelete,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseCardState createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  TextEditingController nameController = TextEditingController();
  TextEditingController setsController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.exercise.name;
    setsController.text = widget.exercise.sets.toString();
    repsController.text = widget.exercise.reps.toString();
    weightController.text = widget.exercise.weight.toString();

    if (setsController.text == "-1") {
      setsController.text = "";
    }
    if (repsController.text == "-1") {
      repsController.text = "";
    }
    if (weightController.text == "-1.0") {
      weightController.text = "";
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: UniqueKey(),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        // side: const BorderSide(
        //   color: hiveBlack,
        //   width: 0.02,
        // ),
      ),
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter Exercise Name...',
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w600, color: hiveSecTextGrey),
                ),
                onChanged: (value) {
                  widget.exercise.name = value;
                },
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 7.0),
                        child: Text(
                          'Sets',
                          style: TextStyle(
                            color: hiveSecTextGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          controller: setsController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: hiveYellow,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: const EdgeInsets.only(top: 17),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintText: "0",
                          ),
                          onChanged: (value) {
                            widget.exercise.sets = int.parse(value);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[0-9]+$')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 30.0,
                        left: 8.0,
                        right: 8.0,
                        bottom: 8.0,
                      ),
                      child: Text(
                        'x',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 7.0),
                        child: Text(
                          'Reps',
                          style: TextStyle(
                            color: hiveSecTextGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          controller: repsController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: hiveYellow,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: const EdgeInsets.only(top: 17),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            hintText: "0",
                          ),
                          onChanged: (value) {
                            widget.exercise.reps = int.parse(value);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[0-9]+$')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(''),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 7.0),
                        child: Text(
                          'Weight (Kg)',
                          style: TextStyle(
                            color: hiveSecTextGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          controller: weightController,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 2,
                                  color: hiveYellow,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: const EdgeInsets.only(top: 17),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: "0.0",
                              suffixStyle: const TextStyle(
                                color: hiveBlack,
                              )),
                          onChanged: (value) {
                            widget.exercise.weight = double.parse(value);
                          },
                          // Filter for only double input
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,1}$')),
                            // FilteringTextInputFormatter.allow(
                            //     RegExp(r'^[0-9]+$')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// =========================================================================================================================
// Class of timer used to display the time to the user
// =========================================================================================================================

class TimerWidget extends StatefulWidget {
  @override
  _TimerWidgetState createState() => _TimerWidgetState();

  Duration get currentDuration {
    _TimerWidgetState state = _TimerWidgetState();
    return state.duration;
  }
}

class _TimerWidgetState extends State<TimerWidget> {
  Duration duration = const Duration();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void addTime() {
    const addSeconds = 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      buildTime(),
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Color.fromRGBO(96, 101, 102, 1),
      ),
    );
  }

  String buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
