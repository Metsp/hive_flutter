import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/screens/add_screen.dart';
import 'package:hive_flutter/screens/feed_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';

const webScreenSize = 600; //Setting a standard screen size

List<Widget> homeScreenItems = [
  FeedScreen(),
  SearchScreen(),
  AddScreen(),
  Text('notifications'),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
