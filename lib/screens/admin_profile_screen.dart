import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/screens/admin_post_screen.dart';
import 'package:hive_flutter/screens/followers_screen.dart';
import 'package:hive_flutter/screens/following_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/utils/utils.dart';
import 'package:hive_flutter/widgets/admin_profile_workout_card.dart';

class AdminProfileScreen extends StatefulWidget {
  final String uid;
  const AdminProfileScreen({super.key, required this.uid});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen>
    with TickerProviderStateMixin {
  Future<void> refreshScreen() async {
    setState(() {
      getData();
    });
  }

  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isLoading = false;
  bool hasPosts = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  // Used to get data from the user
  getData() async {
    isLoading = true;
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // Getting the user data, post etc
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;

      // Check if user has any posts
      if (postLen == 0) {
        hasPosts = false;
      } else {
        hasPosts = true;
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
    TabController tabController = TabController(length: 2, vsync: this);
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: hiveYellow,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: hiveBlack),
                onPressed: () => Navigator.of(context).pop(),
              ),
              automaticallyImplyLeading: false,
              backgroundColor: hiveWhite,
              elevation: 0,
              title: Text(
                userData['username'],
                style: const TextStyle(
                  color: hiveBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              // actions: <Widget>[
              //   Padding(
              //     padding: const EdgeInsets.only(right: 10.0),
              //     child: IconButton(
              //       icon: const Icon(Icons.delete_forever_rounded),
              //       iconSize: 25,
              //       color: hiveBlack,
              //       onPressed: () {},
              //     ),
              //   )
              // ],
            ),
            body: RefreshIndicator(
              onRefresh: refreshScreen,
              color: hiveBlack,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  NetworkImage(userData['photoUrl']),
                              radius: 40,
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildStatColumn(postLen, "Posts"),
                                      InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FollowersScreen(
                                                  userID: userData['uid'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: buildStatColumn(
                                              followers, "Followers")),
                                      InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FollowingScreen(
                                                  userID: userData['uid'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: buildStatColumn(
                                              following, "Following")),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 10, left: 5),
                          child: Text(
                            userData['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: hiveBlack,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 2, left: 4),
                          child: Text(
                            userData['bio'],
                            style: const TextStyle(
                              color: hiveDarkGrey,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                  ),
                  Column(
                    children: [
                      TabBar(
                        labelColor: hiveBlack,
                        unselectedLabelColor: Colors.grey,
                        controller: tabController,
                        indicatorColor: hiveYellow,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.grid_on_rounded),
                          ),
                          Tab(
                            icon: Icon(Icons.fitness_center_rounded),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            //Future builder used to show the posts of the user
                            hasPosts
                                ? FutureBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                    future: FirebaseFirestore.instance
                                        .collection('posts')
                                        .where('uid', isEqualTo: widget.uid)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: hiveYellow,
                                          ),
                                        );
                                      }

                                      var data = (snapshot.data! as dynamic)
                                          .docs
                                          .where((doc) =>
                                              doc['datePublished'] != null)
                                          .toList()
                                        ..sort((a, b) => b['datePublished']
                                                .compareTo(a['datePublished'])
                                            as int);

                                      // Grid view to show user profile posts
                                      return GridView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing:
                                              1, // Default value 5
                                          mainAxisSpacing: 1.5,
                                          childAspectRatio: 1,
                                        ),
                                        itemBuilder: (context, index) {
                                          DocumentSnapshot snap = data[index];

                                          // Gesture detector to open post page
                                          return GestureDetector(
                                            onTap: () =>
                                                Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AdminPostScreen(
                                                  snap: snap.data(),
                                                ),
                                              ),
                                            ),
                                            child: Image(
                                              image:
                                                  NetworkImage(snap['postUrl']),
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : Center(
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      // crossAxisAlignment:
                                      //     CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.19,
                                        ),
                                        const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 70,
                                        ),
                                        const Text(
                                          'No Posts',
                                          style: TextStyle(
                                            color: hiveBlack,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            Center(
                              child: Expanded(
                                child: Column(
                                  children: [
                                    FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.uid)
                                          .collection('workouts')
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Expanded(
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: hiveYellow,
                                              ),
                                            ),
                                          );
                                        }

                                        bool isCollectionEmpty =
                                            (snapshot.data! as dynamic)
                                                .docs
                                                .isEmpty;

                                        if (isCollectionEmpty) {
                                          return Center(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.19,
                                                ),
                                                const Icon(
                                                  Icons.hourglass_empty,
                                                  size: 70,
                                                ),
                                                const Text(
                                                  'No Workouts',
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
                                          return Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: ListView.builder(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount:
                                                    (snapshot.data! as dynamic)
                                                        .docs
                                                        .length,
                                                itemBuilder: (context, index) {
                                                  // ignore: unused_local_variable
                                                  DocumentSnapshot snap =
                                                      (snapshot.data!
                                                              as dynamic)
                                                          .docs[index];
                                                  return AdminProfileWorkoutCard(
                                                    snap: (snapshot.data!
                                                            as dynamic)
                                                        .docs[index]
                                                        .data(),
                                                    refreshCallback: () {
                                                      refreshScreen();
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  // Functions used to make columns for the profile statistics
  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: hiveBlack,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: hiveDarkGrey,
            ),
          ),
        ),
      ],
    );
  }
}
