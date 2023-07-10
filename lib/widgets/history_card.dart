import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:intl/intl.dart';

import '../utils/utils.dart';

class HistoryCard extends StatefulWidget {
  final VoidCallback refreshCallback;
  // ignore: prefer_typing_uninitialized_variables
  final snap;
  const HistoryCard(
      {super.key, required this.snap, required this.refreshCallback});

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20),
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
                          deleteWorkoutHistory(widget.snap['historyID']);
                        },
                        child: const Icon(
                          Icons.delete_rounded,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('EEEE, d MMM y')
                              .format(widget.snap['workoutDate'].toDate()),
                          // 'Monday, 1 Aug 2022',
                          style: const TextStyle(
                            color: hiveDarkGrey,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 2),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 3.0),
                              child: Icon(
                                Icons.access_time_rounded,
                                size: 18,
                              ),
                            ),
                            Text(
                              widget.snap['workoutDuration'],
                              // '1h 9m',
                              style: const TextStyle(
                                color: hiveDarkGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 3.0, top: 2),
                              child: Icon(
                                Icons.monitor_weight_rounded,
                                size: 18,
                              ),
                            ),
                            Text(
                              '${widget.snap['workoutWeight']} kg',
                              // '6578 kg',
                              style: const TextStyle(
                                color: hiveDarkGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      top: 2,
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

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Workout History'),
          content:
              const Text('Are you sure you want to delete this workout log?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void refreshPage() {
    widget.refreshCallback();
  }

  // Deleting workout history function
  Future<void> deleteWorkoutHistory(String historyId) async {
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
            title: const Text(
              'Delete Workout History',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('workoutHistory')
                        .doc(historyId)
                        .delete();
                    refreshPage();
                    // ignore: use_build_context_synchronously
                    showSnackBar('Workout History Deleted!', context);
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
