import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/colors.dart';
import '../utils/utils.dart';
import 'edit_profile_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Define a boolean flag to indicate whether the screen needs to be refreshed
  bool isLoading = false;
  String userAge = '';
  String userHeight = '';
  String userWeight = '';
  String userGender = 'Male';
  String userIdealWeight = '';
  String userBMI = '';
  String userBmiStatus = '';
  String userBmiResult = '';
  Color BMICardColor = hiveLightGreen;

  bool hasWorkout = false;
  bool hasHistory = false;

  Future<void> refreshScreen() async {
    setState(() {
      getData();
    });
  }

  // Used to get data from the user
  getData() async {
    isLoading = true;
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userAge = userSnap.data()!['age'];
      userHeight = userSnap.data()!['height'];
      userWeight = userSnap.data()!['weight'];
      userGender = userSnap.data()!['gender'];

      // Calculating user BMI
      double heightMeters = double.parse(userHeight);
      double weightDouble = double.parse(userWeight);

      userBMI = (weightDouble / (heightMeters / 100 * heightMeters / 100))
          .toStringAsFixed(1);

      if (double.parse(userBMI) <= 18.5) {
        userBmiStatus = "Status: Underweight";
        userBmiResult =
            "You are underweight, your goal should be to eat more calories to gain weight.";
        BMICardColor = hiveYellow;
      }
      if (double.parse(userBMI) >= 18.6 && double.parse(userBMI) <= 25.0) {
        userBmiStatus = "Status: Normal";
        userBmiResult =
            "Your BMI is in the normal range, you should maintain your weight!";
        BMICardColor = const Color.fromARGB(255, 71, 255, 105);
      }
      if (double.parse(userBMI) >= 25.1 && double.parse(userBMI) <= 34.9) {
        userBmiStatus = "Status: Overweight";
        userBmiResult =
            "Based on the BMI scale, you are overweight, your goal should be to eat less calories and lose fat.";
        BMICardColor = hiveYellow;
      }

      if (double.parse(userBMI) >= 35.0) {
        userBmiStatus = "Status: Obese";
        userBmiResult =
            "Based on the BMI scale, you are obese, your goal should be to eat less calories and lose fat, weight as well as exercise more.";
        BMICardColor = const Color.fromARGB(255, 255, 71, 71);
      }

      // Calculating Ideal Body Weight
      if (userGender == "Male" || userGender == "Others") {
        userIdealWeight =
            (50 + (2.3 * ((double.parse(userHeight) * 0.3937) - 60)))
                .toStringAsFixed(1);
      } else if (userGender == "Female") {
        userIdealWeight =
            (45.5 + (2.3 * ((double.parse(userHeight) * 0.3937) - 60)))
                .toStringAsFixed(1);
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

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: hiveWhite,
          centerTitle: false,
          elevation: 0,
          title: SvgPicture.asset(
            'assets/hive_logo_banner_dark.svg',
            height: 64,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    getData();
                  });
                },
                color: hiveBlack,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 25,
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: hiveYellow,
                ),
              )
            : RefreshIndicator(
                onRefresh: refreshScreen,
                color: hiveBlack,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 5, left: 20, right: 20),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Health',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Body Mass Index (BMI)',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: hiveDarkGrey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Card(
                        color: BMICardColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: const EdgeInsets.only(
                            bottom: 15, top: 15, left: 15, right: 25),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 15, left: 10, right: 10),
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text(
                                  'BMI',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hiveBlack,
                                  ),
                                ),
                                subtitle: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          userBMI,
                                          style: const TextStyle(
                                              fontSize: 50,
                                              fontWeight: FontWeight.bold,
                                              color: hiveBlack),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          userBmiStatus,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: hiveBlack),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 3.0),
                                  child: Text(
                                    'Result',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: hiveDarkGrey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Flexible(
                          child: Text(
                            userBmiResult,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: hiveDarkGrey),
                            softWrap: true,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Divider(),
                      ),
                      // =============================================================================================================
                      // Ideal Body Weight Section
                      // =============================================================================================================

                      const Padding(
                        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Ideal Body Weight',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: hiveDarkGrey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: const EdgeInsets.only(
                            bottom: 15, top: 15, left: 15, right: 25),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 15, left: 10, right: 10),
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text(
                                  'Your Ideal Body Weight',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hiveBlack,
                                  ),
                                ),
                                subtitle: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "$userIdealWeight kg+-",
                                          style: const TextStyle(
                                              fontSize: 50,
                                              fontWeight: FontWeight.bold,
                                              color: hiveBlack),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Flexible(
                          child: Text(
                            'Your ideal body weight is calculated based on your gender, weight, and height using the B.J Devine Formula (1974). The range of your ideal weight may still vary based on many different factors, so take the ideal body weight calculation with a grain of salt, especially if you are a bodybuilder.',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: hiveDarkGrey),
                            softWrap: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Flexible(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Wrong Information? Click here to update your details',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: hiveBlue),
                              softWrap: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
