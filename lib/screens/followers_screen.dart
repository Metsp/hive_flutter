import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/widgets/user_profile_card.dart';

import '../utils/utils.dart';

class FollowersScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final String userID;
  const FollowersScreen({super.key, required this.userID});

  @override
  State<FollowersScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowersScreen> {
  int followersLen = 0;
  List followers = [];
  bool isLoading = false;
  bool hasFollowers = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  // Define a boolean flag to indicate whether the screen needs to be refreshed
  bool refreshScreen = false;

  // Callback function to handle the refresh
  void refresh() {
    setState(() {
      refreshScreen = true;
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

      followers = userSnap.data()!['followers'];
      followersLen = userSnap.data()!['followers'].length;

      if (followersLen == 0) {
        hasFollowers = false;
      } else {
        hasFollowers = true;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: hiveBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: hiveWhite,
        elevation: 0.5,
        title: const Text(
          'Following',
          style: TextStyle(
            color: hiveBlack,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              iconSize: 25,
              color: hiveBlack,
              onPressed: () {
                setState(() {
                  getData();
                });
              },
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: hiveYellow,
              ),
            )
          : hasFollowers
              ? Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('uid', whereIn: followers)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: hiveYellow,
                              ),
                            );
                          }
                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount:
                                        (snapshot.data! as dynamic).docs.length,
                                    itemBuilder: (context, index) => UserCard(
                                          snap: (snapshot.data! as dynamic)
                                              .docs[index]
                                              .data(),
                                        )),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Icon(
                        Icons.portrait,
                        size: 70,
                      ),
                      Text(
                        'No Followers',
                        style: TextStyle(
                          color: hiveBlack,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
    );
  }
}
