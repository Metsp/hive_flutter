import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/screens/admin_profile_screen.dart';
import 'package:hive_flutter/utils/colors.dart';

class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  State<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  QuerySnapshot querySnapshot =
                      snapshot.data as QuerySnapshot<Object?>;
                  List<DocumentSnapshot> documents = querySnapshot.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AdminProfileScreen(
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
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Icon(
                    Icons.manage_search_rounded,
                    size: 70,
                  ),
                  Text(
                    'Search for a user',
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
