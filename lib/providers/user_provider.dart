import 'package:flutter/material.dart';
import 'package:hive_flutter/models/user.dart';
import 'package:hive_flutter/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
    // Notify all listeners to this user provider, that data of the global variable "user" has changed,
    // so the value should be updated.
  }
}
