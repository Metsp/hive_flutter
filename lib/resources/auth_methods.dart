import "dart:typed_data";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:hive_flutter/models/user.dart" as model;
import "package:hive_flutter/resources/storage_methods.dart";

class AuthMethods {
  //Class of methods for authenticating users
  final FirebaseAuth _auth =
      FirebaseAuth.instance; //Creates an instance of the firebase class to use
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    //Used to get all user data once, to be reused in the system
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  //Sign up the user
  Future<String> signUpUser({
    //The function's return type is Future<string> as the function should be asynchronious, and return a string based on the authentication result (res)
    required String email,
    required String password,
    required String username,
    required String bio,
    required String age,
    required String height,
    required String weight,
    required String gender,
    required Uint8List file, //Profile picture file
  }) async {
    String res = "Please fill in all the required fields";
    try {
      // Register the user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ignore: avoid_print
      print(cred.user!.uid);
      /*The auth method used returns a Future type data "userCredential", thus await needs to be used to wait for the data
        The variable cred will return many information which can be accessed by "." */

      String photoUrl = await StorageMethods()
          .uploadImageToStorage('profilepics', file, false);

      // Add user to our database

      model.User user = model.User(
        username: username,
        uid: cred.user!.uid,
        email: email,
        bio: bio,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
        photoUrl: photoUrl,
        following: [],
        followers: [],
      );

      await _firestore.collection('users').doc(cred.user!.uid).set(
            user.toJson(),
          );

      res = "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is not formatted correctly';
      }
      if (err.code == 'email-already-in-use') {
        res = 'The email is already in use';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Logging in the user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Wrong credentials, Invalid email or password";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please fill in all required fields";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == "invalid-email") {
        res = "Email does not exist";
      } else if (err.code == "wrong-password" || err.code == "invalid-email") {
        res = "Wrong credentials, Invalid email or password";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Sign out the user
  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}
