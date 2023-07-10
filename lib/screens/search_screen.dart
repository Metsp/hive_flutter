import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/screens/post_screen.dart';
import 'package:hive_flutter/screens/profile_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: hiveWhite,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
              labelText: 'Search for a user',
              labelStyle: TextStyle(color: hiveBlack)),
          onFieldSubmitted: (String _) {
            setState(
              () {
                isShowUsers = true;
              },
            );
          },
        ),
        actions: [
          isShowUsers
              ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                    onPressed: () {
                      setState(
                        () {
                          isShowUsers = false;
                        },
                      );
                    },
                    color: hiveBlack,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 25,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: hiveYellow,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: hiveYellow,
                    ),
                  );
                } else {
                  // Used to remove searching your own account
                  QuerySnapshot querySnapshot =
                      snapshot.data as QuerySnapshot<Object?>;
                  List<DocumentSnapshot> documents = querySnapshot.docs;

                  // Exclude the document with 'uid' equal to "user.uid"
                  documents.removeWhere((doc) =>
                      (doc.data() as Map<String, dynamic>)['uid'] == user.uid);

                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              uid: documents[index]['uid'],
                            ),
                          ),
                        ),
                        child: ListTile(
                          // Used as a "card" for other user information
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              documents[index]['photoUrl'],
                            ),
                          ),
                          title: Text(
                            documents[index]['username'],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            )
          : FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', isNotEqualTo: user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: hiveYellow,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: hiveYellow,
                    ),
                  );
                }

                var data = snapshot.data!.docs
                    .where((doc) => doc['datePublished'] != null)
                    .toList()
                  ..sort((a, b) =>
                      b['datePublished'].compareTo(a['datePublished']));

                return StaggeredGridView.countBuilder(
                  crossAxisCount: 3,
                  itemCount: data.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostScreen(
                          snap: data[index].data(),
                        ),
                      ),
                    ),
                    child: Image.network(
                      data[index]['postUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  staggeredTileBuilder: (index) => StaggeredTile.count(
                    (index % 7 == 0) ? 2 : 1,
                    (index % 7 == 0) ? 2 : 1,
                  ),
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                );
              },
            ),
    );
  }
}
