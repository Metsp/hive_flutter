import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
// Define a boolean flag to indicate whether the screen needs to be refreshed
  bool refreshScreen = false;
  bool isLoading = false;

// Define workoutHistoryMap variable outside the function
  Map<DateTime, int> workoutHistoryMap = {};

  void getWorkoutHistory() async {
    isLoading = true;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('workoutHistory')
          .get();

      int workoutLen = querySnapshot.size;

      if (workoutLen == 0) {
        workoutHistoryMap = {};
      } else {
        for (var document in querySnapshot.docs) {
          Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
          if (data != null) {
            Timestamp? workoutDate = data['workoutDate'];
            if (workoutDate != null) {
              DateTime date = workoutDate.toDate();
              int workoutYear = date.year;
              int workoutMonth = date.month;
              int workoutDay = date.day;

              print('Year: $workoutYear');
              print('Month: $workoutMonth');
              print('Day: $workoutDay');

              final dailyWorkout = <DateTime, int>{
                DateTime(workoutYear, workoutMonth, workoutDay): 1
              };

              workoutHistoryMap.addEntries(dailyWorkout.entries);
              print(workoutHistoryMap);
            }
          }
        }
      }

      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(
      () {
        isLoading = false;
      },
    );
  }

  // Callback function to handle the refresh
  void refresh() {
    getWorkoutHistory();
    setState(() {
      refreshScreen = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getWorkoutHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 20,
            right: 20,
          ),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Workout History',
                        style: TextStyle(
                          fontSize: 25,
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
            ],
          ),
        ),
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 23,
                right: 20,
                bottom: 15,
              ),
              child: Row(
                children: [
                  Text(
                    'Use the heatmap below to track your daily workouts!',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hiveDarkGrey),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: hiveYellow,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Material(
                      elevation: 2,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, bottom: 20.0),
                          child: HeatMapCalendar(
                            showColorTip: false,
                            defaultColor: hiveWhite,
                            textColor: hiveBlack,
                            flexible: false,
                            size: 38,
                            colorMode: ColorMode.opacity,
                            weekTextColor: hiveBlack,
                            datasets: workoutHistoryMap,
                            colorsets: const {
                              1: hiveYellow,
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0, bottom: 15),
                  child: Text(
                    'Previous Workouts',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('workoutHistory')
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
                    SizedBox(
                      height: 30,
                    ),
                    Icon(
                      Icons.list_alt_rounded,
                      size: 70,
                    ),
                    Text(
                      'No History',
                      style: TextStyle(
                        color: hiveBlack,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                  // Gesture dedector to open post page
                  return HistoryCard(
                    snap: (snapshot.data! as dynamic).docs[index].data(),
                    refreshCallback: refresh,
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
