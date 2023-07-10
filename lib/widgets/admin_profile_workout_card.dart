import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/utils/colors.dart';

import '../utils/utils.dart';

class AdminProfileWorkoutCard extends StatefulWidget {
  final VoidCallback refreshCallback;
  final snap;
  const AdminProfileWorkoutCard(
      {super.key, required this.snap, required this.refreshCallback});

  @override
  State<AdminProfileWorkoutCard> createState() =>
      _AdminProfileWorkoutCardState();
}

class _AdminProfileWorkoutCardState extends State<AdminProfileWorkoutCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16.0, right: 16.0, top: 10, bottom: 5),
        child: Material(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          elevation: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.snap['workoutName'],
                        style: const TextStyle(
                          color: hiveBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          deleteWorkout(widget.snap['workoutID']);
                        },
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Exercises',
                          style: TextStyle(
                            color: hiveBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.snap['workoutExercises'],
                            // 'Pull Ups: 25kg x 4 Sets \nLeg Press: 25kg x 4 Sets \nIncline Barbell Curls: 25kg x 4 Sets \nSit Ups: 25kg x 4 Sets',
                            style: const TextStyle(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void refreshPage() {
    widget.refreshCallback();
  }

  // Deleting workout history function
  Future<void> deleteWorkout(String workoutID) async {
    final firestore = FirebaseFirestore.instance;
    try {
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
            title: Text(
              'Delete ${widget.snap['workoutName']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to delete this workout?',
              style: TextStyle(
                  fontWeight: FontWeight.w400, color: hiveBlack, fontSize: 17),
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
                    style: TextStyle(
                        color: hiveBlack, fontWeight: FontWeight.bold),
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
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await firestore
                        .collection('users')
                        .doc(widget.snap['userID'])
                        .collection('workouts')
                        .doc(workoutID)
                        .delete();
                    // ignore: use_build_context_synchronously
                    refreshPage();
                    // ignore: use_build_context_synchronously
                    showSnackBar('Workout Deleted!', context);
                  },
                ),
              ),
            ],
          );
        },
      );
    } catch (err) {
      print(err.toString());
    }
  }
}
