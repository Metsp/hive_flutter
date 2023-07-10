import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import 'admin_post_screen.dart';
import 'landing_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Define a boolean flag to indicate whether the screen needs to be refreshed
  bool isLoading = false;
  int userLen = 0;
  int postLen = 0;

  // Used to get data for admins
  getData() async {
    isLoading = true;
    try {
      // Getting users count
      var userSnap =
          await FirebaseFirestore.instance.collection('users').count().get();
      userLen = userSnap.count;

      // Getting posts count
      var postSnap =
          await FirebaseFirestore.instance.collection('posts').count().get();
      postLen = postSnap.count;

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

  Future<void> refreshScreen() async {
    setState(() {
      getData();
    });
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
                  refreshScreen();
                },
                color: hiveBlack,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 25,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded),
                iconSize: 25,
                color: hiveBlack,
                onPressed: () {
                  signOutAdmin();
                },
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
            : ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, left: 20, right: 20),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 15, left: 10, right: 10),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: const Text(
                                          'Users',
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
                                                  userLen.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 15, left: 10, right: 10),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: const Text(
                                          'Posts',
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
                                                  postLen.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 50,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 15, left: 20, right: 20),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Reported Posts',
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
                  //Reports Stream
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: hiveYellow,
                            ),
                          );
                        }

                        final posts = snapshot.data!.docs;
                        final filteredPosts = posts
                            .where((post) =>
                                (post['reports'] as List<dynamic>).isNotEmpty)
                            .toList();

                        if (filteredPosts.isNotEmpty) {
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredPosts.length,
                            itemBuilder: (context, index) {
                              final post = filteredPosts[index];
                              final reportsLength =
                                  (post['reports'] as List<dynamic>).length;

                              return InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AdminPostScreen(
                                      snap:
                                          snapshot.data!.docs[index + 1].data(),
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 5.0,
                                      left: 10,
                                      right: 10),
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
                                      child: ListTile(
                                        leading: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              post['profImage'],
                                            ),
                                            radius: 25,
                                          ),
                                        ),
                                        title: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3.0),
                                          child: Text(
                                            post['username'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            const Row(
                                              children: [
                                                Text(
                                                  "Post ID:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            Text("${post['postId']}"),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Report Count:",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(" $reportsLength"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        isThreeLine: true,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 70,
                                ),
                                Icon(
                                  Icons.camera_alt_rounded,
                                  size: 70,
                                ),
                                Text(
                                  'No Reported Posts',
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
                ],
              ),
      ),
    );
  }

  Future<void> signOutAdmin() async {
    // final firestore = FirebaseFirestore.instance;
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
              'Sign out?',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                    'Sign Out',
                    style: TextStyle(
                      color: hiveBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LandingScreen()),
                        (Route<dynamic> route) => false);
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
