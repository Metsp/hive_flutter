import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final String age;
  final String height;
  final String weight;
  final String gender;
  final List followers;
  final List following;

  const User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.bio,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "age": age,
        "height": height,
        "weight": weight,
        "gender": gender,
        "followers": followers,
        "following": following,
      };

  //Function to return a document snapshot and return a "user" model, to be used to get data
  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      bio: snapshot['bio'],
      age: snapshot['age'],
      height: snapshot['height'],
      weight: snapshot['weight'],
      gender: snapshot['gender'],
      followers: snapshot['followers'],
      following: snapshot['following'],
    );
  }
}
