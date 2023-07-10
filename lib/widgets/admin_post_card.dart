import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/resources/firestore_methods.dart';
import 'package:hive_flutter/screens/admin_profile_screen.dart';
import 'package:hive_flutter/utils/colors.dart';
import 'package:hive_flutter/utils/utils.dart';
import 'package:hive_flutter/widgets/like_animation.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/admin_comments_screen.dart';
import '../screens/profile_screen.dart';

class AdminPostCard extends StatefulWidget {
  final snap;
  const AdminPostCard({super.key, required this.snap});

  @override
  State<AdminPostCard> createState() => _AdminPostCardState();
}

class _AdminPostCardState extends State<AdminPostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;
  bool isUser = false;
  bool noComments = false;
  int reports = 0;
  bool hasReports = true;
  var postData = {};

  @override
  void initState() {
    super.initState();
    getPostData();
  }

  // Function to get the number of comments for a post
  void getPostData() async {
    try {
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .get();

      postData = postSnap.data()!;
      reports = postSnap.data()!['reports'].length;

      if (reports == 0) {
        hasReports = false;
      }

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();

      commentLen = snap.docs.length;
      if (commentLen == 0) {
        noComments = true;
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  void deletePost() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      color: hiveWhite,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: widget.snap['uid'],
                      ),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'],
                    ),
                    backgroundColor: hiveLightGrey,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdminProfileScreen(
                                uid: widget.snap['uid'],
                              ),
                            ),
                          ),
                          child: Text(
                            widget.snap['username'],
                            style: const TextStyle(
                              color: hiveBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          children: [
                            'Delete Post',
                            'Clear Reports',
                          ]
                              .map(
                                (e) => InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    if (e == 'Delete Post') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            actionsAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 5,
                                                    left: 20,
                                                    right: 20),
                                            contentTextStyle: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                            backgroundColor: hiveWhite,
                                            title: const Text(
                                              'Delete Post',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this post?',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: hiveBlack,
                                                  fontSize: 17),
                                            ),
                                            actions: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor: Colors
                                                        .transparent, // Background color
                                                  ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: hiveBlack,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        hiveYellow, // Background color
                                                  ),
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      color: hiveBlack,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    FirestoreMethods()
                                                        .deletePost(widget
                                                            .snap['postId']);
                                                    Navigator.pop(
                                                        context, 'Yes');
                                                    showSnackBar("Post Deleted",
                                                        context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      // showDialog<String>(
                                      //   context: context,
                                      //   builder: (BuildContext context) =>
                                      //       AlertDialog(
                                      //     content:
                                      //         const Text('Confirm Deletion?'),
                                      //     actions: <Widget>[
                                      //       TextButton(
                                      //         onPressed: () => Navigator.pop(
                                      //             context, 'Cancel'),
                                      //         child: const Text(
                                      //           'Cancel',
                                      //           style: TextStyle(
                                      //             color: hiveBlack,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       TextButton(
                                      //         onPressed: () async {
                                      //           FirestoreMethods().deletePost(
                                      //               widget.snap['postId']);
                                      //           Navigator.pop(context, 'Yes');
                                      //           showSnackBar(
                                      //               "Post Deleted", context);
                                      //         },
                                      //         child: const Text(
                                      //           'Yes',
                                      //           style: TextStyle(
                                      //             color: hiveBlack,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // );
                                      // Clearing all reports
                                    } else if (e == 'Clear Reports') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            actionsAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 5,
                                                    left: 20,
                                                    right: 20),
                                            contentTextStyle: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                            backgroundColor: hiveWhite,
                                            title: const Text(
                                              'Clear Reports',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: const Text(
                                              'Clear all reports for this post??',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: hiveBlack,
                                                  fontSize: 17),
                                            ),
                                            actions: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor: Colors
                                                        .transparent, // Background color
                                                  ),
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: hiveBlack,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        hiveYellow, // Background color
                                                  ),
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      color: hiveBlack,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    FirestoreMethods()
                                                        .clearPostReports(widget
                                                            .snap['postId']);
                                                    showSnackBar(
                                                        "Reports cleared",
                                                        context);
                                                    Navigator.pop(context,
                                                        'Clear Reports');
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      // showDialog<String>(
                                      //   context: context,
                                      //   builder: (BuildContext context) =>
                                      //       AlertDialog(
                                      //     content: const Text(
                                      //         'Clear all reports for this post?'),
                                      //     actions: <Widget>[
                                      //       TextButton(
                                      //         onPressed: () => Navigator.pop(
                                      //             context, 'Cancel'),
                                      //         child: const Text(
                                      //           'Cancel',
                                      //           style: TextStyle(
                                      //             color: hiveBlack,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       TextButton(
                                      //         onPressed: () async {
                                      //           FirestoreMethods()
                                      //               .clearPostReports(
                                      //                   widget.snap['postId']);
                                      //           showSnackBar(
                                      //               "Reports cleared", context);
                                      //           Navigator.pop(
                                      //               context, 'Clear Reports');
                                      //         },
                                      //         child: const Text(
                                      //           'Yes',
                                      //           style: TextStyle(
                                      //             color: hiveBlack,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    child: Text(e),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                )
              ],
            ),
          ),

          //Image Section
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                // height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child: Image.network(
                  widget.snap['postUrl'],
                  fit: BoxFit.fill, // Used to be contain
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLikeAnimating ? 1 : 0,
                child: LikeAnimation(
                  isAnimating: isLikeAnimating,
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                  onEnd: () {
                    setState(() {
                      isLikeAnimating = false;
                    });
                  },
                  child: const Icon(
                    Icons.favorite,
                    color: hiveWhite,
                    size: 100,
                  ),
                ),
              )
            ],
          ),

          // Likes / Comments section
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdminCommentsScreen(
                      snap: widget.snap,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
            ],
          ),

          // Description / Number of Comments
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${widget.snap['likes'].length} likes', // String interpolation as "likes" is an array value
                    style: const TextStyle(
                        color: hiveBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 7),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                          color: hiveWhite,
                        ),
                        children: [
                          TextSpan(
                            text: widget.snap['username'],
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AdminProfileScreen(
                                        uid: widget.snap['uid'],
                                      ),
                                    ),
                                  ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: hiveBlack,
                            ),
                          ),
                          TextSpan(
                              text: ' ${widget.snap['description']}',
                              style: const TextStyle(
                                color: hiveBlack,
                              ))
                        ]),
                  ), // Rich Text is able to expand to fit user requirements
                ),
                noComments
                    ? Container(
                        padding: const EdgeInsets.only(
                          bottom: 7,
                        ),
                      )
                    : InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AdminCommentsScreen(
                              snap: widget.snap,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'View all $commentLen comments',
                            style: const TextStyle(
                              fontSize: 14,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                Text(
                  timeago.format(widget.snap['datePublished'].toDate()),
                  // DateFormat.yMMMd().format(
                  //   widget.snap['datePublished'].toDate(),
                  // ), // Using the "intl" package to format the timestamp
                  style: const TextStyle(
                    fontSize: 12,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
