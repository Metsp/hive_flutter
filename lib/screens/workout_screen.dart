import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/screens/active_workout_screen.dart';
import 'package:hive_flutter/screens/empty_workout_screen.dart';
import 'package:hive_flutter/widgets/workout_card.dart';

import '../utils/colors.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Define a boolean flag to indicate whether the screen needs to be refreshed
  bool refreshScreen = false;

  // Callback function to handle the refresh
  void refresh() {
    setState(() {
      refreshScreen = true;
    });
  }

  bool hasWorkout = false;
  bool hasHistory = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Start your Workout',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EmptyWorkoutScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: hiveYellow,
                border: Border.all(color: hiveYellow),
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              height: 40,
              child: const Text(
                "Start an Empty Workout ",
                style: TextStyle(
                    color: hiveBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Workout Templates',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          refresh();
                        },
                        color: hiveBlack,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmptyWorkoutScreen()),
                  );
                },
                color: hiveBlack,
                icon: const Icon(
                  Icons.add_box_rounded,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('workouts')
              .orderBy('workoutDate', descending: true)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: hiveYellow,
                  ),
                ),
              );
            }

            bool isCollectionEmpty = (snapshot.data! as dynamic).docs.isEmpty;

            if (isCollectionEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        Icon(
                          Icons.hourglass_empty,
                          size: 70,
                        ),
                        Text(
                          'No Workouts',
                          style: TextStyle(
                            color: hiveBlack,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: (snapshot.data! as dynamic).docs.length,
                itemBuilder: (context, index) {
                  // ignore: unused_local_variable
                  DocumentSnapshot snap =
                      (snapshot.data! as dynamic).docs[index];
                  // Gesture dedector to open active workout page
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          contentPadding: const EdgeInsets.only(
                              top: 20, bottom: 5, left: 24, right: 24),
                          contentTextStyle:
                              const TextStyle(fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          backgroundColor: hiveWhite,
                          title: Text(
                            '${(snapshot.data! as dynamic).docs[index].data()['workoutName']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            '${(snapshot.data! as dynamic).docs[index].data()['workoutExercises']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: hiveBlack,
                                fontSize: 17),
                          ),
                          actions: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 4),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Colors.transparent, // Background color
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: hiveBlack,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.of(_).pop();
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      hiveYellow, // Background color
                                ),
                                child: const Text(
                                  'Start Workout',
                                  style: TextStyle(
                                    color: hiveBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(_).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ActiveWorkoutScreen(
                                        snap: (snapshot.data! as dynamic)
                                            .docs[index]
                                            .data(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: WorkoutCard(
                      snap: (snapshot.data! as dynamic).docs[index].data(),
                      refreshCallback: refresh,
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
