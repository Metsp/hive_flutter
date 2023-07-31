import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/models/posts.dart';
import 'package:hive_flutter/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "An error has occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();
      // Using the UUID package to can generate a unique ID based on time

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
        reports: [],
      );
      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Function used to like a post
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  // Function used to post a comment
  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'postID': postId,
          // 'profilePic': profilePic,
          // 'name': name,
          'uid': uid,
          'text': text,
          'commentID': commentId,
          'datePublished': DateTime.now(),
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  // Deleting post function
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  // Deleting post function
  Future<void> clearPostReports(String postId) async {
    try {
      // Reference to the document in the "posts" collection
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      // Update the "reports" field with an empty list
      await postRef.update({'reports': []});
    } catch (err) {
      // ignore: avoid_print
      print(err.toString());
    }
  }

  // Reporting post function
  Future<String> reportPost(
    String postId,
    String uid,
  ) async {
    // ignore: unused_local_variable
    String result = '';
    try {
      DocumentSnapshot snap =
          await _firestore.collection('posts').doc(postId).get();
      List reports = (snap.data()! as dynamic)['reports'];

      if (reports.contains(uid)) {
        // If user already reported, then ignore
        return result = "You have already reported this post!";
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'reports': FieldValue.arrayUnion([uid])
        });
        return result = "Post Reported!";
      }
    } catch (err) {
      print(err.toString());
      return result = err.toString();
    }
  }

  // Follow / Following User
  Future<void> followUser(
    String uid,
    String followId,
  ) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        // If user already follows, then unfollow
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<String>> getFollowingUserIds(String uid) async {
    // Retrieve the current user's document from Firestore
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // Extract the user's 'following' list from the document
    List<dynamic> following = userSnapshot.get('following');

    // Convert the list to a list of strings
    List<String> followingUserIds = following.cast<String>();

    return followingUserIds;
  }

  Future<String> saveWorkoutInformation(
    String uid,
    String workoutId,
    String workoutName,
    String workoutNote,
    String workoutDuration,
    List exercises,
  ) async {
    String res = "An error has occured";
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('workouts')
          .doc(workoutId)
          .set({
        'uid': uid,
        'workoutId': workoutId,
        'workoutName': workoutName,
        'workoutNote': workoutNote,
        'workoutDuration': workoutNote,
      });
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
