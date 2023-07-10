import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/utils/utils.dart';

class ProfileWorkoutCard extends StatefulWidget {
  final snap;
  const ProfileWorkoutCard({super.key, required this.snap});

  @override
  State<ProfileWorkoutCard> createState() => _ProfileWorkoutCardState();
}

class _ProfileWorkoutCardState extends State<ProfileWorkoutCard> {
  bool isUser = false;

  @override
  Widget build(BuildContext context) {
    if (widget.snap['userID'] == FirebaseAuth.instance.currentUser!.uid) {
      isUser = true;
    }

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
                      isUser
                          ? Container()
                          : InkWell(
                              onTap: () {
                                copyWorkoutToAnotherUser(
                                    widget.snap['userID'],
                                    widget.snap['workoutID'],
                                    FirebaseAuth.instance.currentUser!.uid);
                              },
                              child: const Icon(
                                Icons.copy_rounded,
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

  Future<void> copyWorkoutToAnotherUser(String sourceUserId,
      String sourceWorkoutId, String destinationUserId) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        contentPadding:
            const EdgeInsets.only(top: 20, bottom: 5, left: 24, right: 24),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: hiveWhite,
        title: const Text(
          'Copy this workout?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This workout will be saved to your account',
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
                'Copy',
                style: TextStyle(
                  color: hiveBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(_).pop();
                // Fetch the source workout document
                DocumentSnapshot sourceWorkoutSnapshot = await FirebaseFirestore
                    .instance
                    .collection('users')
                    .doc(sourceUserId)
                    .collection('workouts')
                    .doc(sourceWorkoutId)
                    .get();

                if (sourceWorkoutSnapshot.exists) {
                  // Get the data from the source workout document
                  Map<String, dynamic> workoutData =
                      sourceWorkoutSnapshot.data()! as dynamic;

                  // Add a new variable "copiedUserID" with the value of "sourceUserId"
                  workoutData['copiedUserID'] = sourceUserId;

                  // Overwrite the "userID" field with the "destinationUserId"
                  workoutData['userID'] = destinationUserId;

                  // Create a new workout document in the destination user's collection with the same document ID
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(destinationUserId)
                      .collection('workouts')
                      .doc(sourceWorkoutId) // Use the same document ID
                      .set(workoutData);

                  // Fetch all the exercises within the source workout document
                  QuerySnapshot sourceExercisesSnapshot =
                      await sourceWorkoutSnapshot.reference
                          .collection('exercises')
                          .get();

                  // Copy each exercise document to the destination workout collection
                  for (DocumentSnapshot exerciseSnapshot
                      in sourceExercisesSnapshot.docs) {
                    Map<String, dynamic> exerciseData =
                        exerciseSnapshot.data()! as dynamic;

                    // Create a new exercise document in the destination workout collection
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(destinationUserId)
                        .collection('workouts')
                        .doc(
                            sourceWorkoutId) // Use the same workout document ID
                        .collection('exercises')
                        .add(exerciseData);
                  }
                }
                // ignore: use_build_context_synchronously
                showSnackBar('Workout Saved', context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
