import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/utils/colors.dart';

import '../widgets/post_card.dart';

class PostScreen extends StatefulWidget {
  final snap;
  const PostScreen({super.key, required this.snap});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool isLikeAnimating = false;
  int commentLen = 0;

  late Stream<QuerySnapshot<Map<String, dynamic>>> postStream;

  @override
  void initState() {
    super.initState();
    postStream = FirebaseFirestore.instance
        .collection('posts')
        .where('postId', isEqualTo: widget.snap['postId'])
        .snapshots();
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
        title: Text(
          '${widget.snap['username']}\'s Post',
          style: const TextStyle(
            color: hiveBlack,
          ),
        ),
        centerTitle: true,
      ),
      // Displaying a streambuilder showing the post
      body: StreamBuilder(
        stream: postStream,
        // FirebaseFirestore.instance
        //     .collection('posts')
        //     .where('postId', isEqualTo: widget.snap['postId'])
        //     .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: hiveYellow,
              ),
            );
          } else {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) => PostCard(
                  snap: snapshot.data!.docs[index].data(),
                ),
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
                      Icons.delete_forever_rounded,
                      size: 70,
                    ),
                    Text(
                      'Post Deleted',
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
          }
        },
      ),
    );
  }
}
