import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/widgets/post_card.dart';
import '../utils/utils.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  var userData = {};
  var allPostSnap = {};
  int postLen = 0;
  int followers = 0;
  int followingLen = 0;
  List following = [];
  bool isFollowing = false;
  bool isLoading = false;
  bool isUser = false;
  bool anyPosts = false;

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
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'];
      followingLen = userSnap.data()!['following'].length;

      // Check if user is currently following anyone
      if (followingLen == 0) {
        isFollowing = false;
      } else {
        isFollowing = true;

        // Getting the posts where user follows
        var postSnap = await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', whereIn: following)
            .get();
        postLen = postSnap.docs.length;

        if (postLen == 0) {
          anyPosts = false;
        } else {
          anyPosts = true;
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

  Future<void> refreshScreen() async {
    setState(() {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: hiveWhite,
        centerTitle: false,
        elevation: 0,
        title: SvgPicture.asset(
          'assets/hive_logo_banner_dark.svg',
          height: 64,
          // ignore: deprecated_member_use
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                refreshScreen();
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

      // Displaying a stream builder showing all the posts in the feed
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: hiveYellow,
              ),
            )
          : isFollowing
              ? RefreshIndicator(
                  onRefresh: refreshScreen,
                  color: hiveBlack,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Expanded(
                        child: StreamBuilder(
                          //Show this if user is following anyone
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .where('uid', whereIn: following)
                              // .orderBy('datePublished', descending: true)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: hiveYellow,
                                ),
                              );
                            }
                            if (snapshot.hasData &&
                                snapshot.data!.docs.isNotEmpty) {
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      PostCard(
                                        snap: snapshot.data!.docs[index].data(),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // Show this stream if the user follows people, but theres no posts
                              return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('posts')
                                    .where('uid',
                                        isNotEqualTo: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<
                                            QuerySnapshot<Map<String, dynamic>>>
                                        snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: hiveYellow,
                                      ),
                                    );
                                  }
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    return ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                const Icon(
                                                  Icons.portrait,
                                                  size: 70,
                                                ),
                                                const Text(
                                                  'Your following has no posts!',
                                                  style: TextStyle(
                                                    color: hiveBlack,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 8.0,
                                                      left: 20,
                                                      right: 20),
                                                  child: Text(
                                                    'Bored? Follow more people, or look at some of our user\'s posts!!',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                const Divider(),
                                                // The first post
                                                PostCard(
                                                  snap: snapshot
                                                      .data!.docs[index]
                                                      .data(),
                                                )
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Column(
                                            children: [
                                              PostCard(
                                                snap: snapshot.data!.docs[index]
                                                    .data(),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 70,
                                          ),
                                          Text(
                                            'An Error Occured!',
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
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ),
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            Icon(
                              Icons.fitness_center,
                              size: 70,
                            ),
                            Text(
                              'You\'ve reached the end!',
                              style: TextStyle(
                                color: hiveBlack,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 8.0, left: 20, right: 20),
                              child: Text(
                                'Bored? Hit the gym or follow more people!',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              // Show this stream if the user has not followed anyone
              : RefreshIndicator(
                  onRefresh: refreshScreen,
                  color: hiveBlack,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Icon(
                              Icons.portrait,
                              size: 70,
                            ),
                            Text(
                              'You\'re not following anyone!',
                              style: TextStyle(
                                color: hiveBlack,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                  'New to Hive? Have a look at some of our user\'s posts!'),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<
                            List<DocumentSnapshot<Map<String, dynamic>>>>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .where('uid',
                                  isNotEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .snapshots()
                              .map((snapshot) => snapshot.docs
                                  .where((doc) => doc['datePublished'] != null)
                                  .toList()
                                ..sort((a, b) => b['datePublished']
                                    .compareTo(a['datePublished']))),
                          builder: (context,
                              AsyncSnapshot<
                                      List<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: hiveYellow,
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              return Expanded(
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        PostCard(
                                          snap: snapshot.data![index].data(),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            } else {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      size: 70,
                                    ),
                                    Text(
                                      'An Error Occurred!',
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
                              );
                            }
                          },
                        ),
                      ),
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            Icon(
                              Icons.fitness_center,
                              size: 70,
                            ),
                            Text(
                              'You\'ve reached the end!',
                              style: TextStyle(
                                color: hiveBlack,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 8.0, left: 20, right: 20),
                              child: Text(
                                'Bored? Hit the gym or follow more people!',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
