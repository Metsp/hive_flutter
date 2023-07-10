import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/screens/search_screen.dart';
import 'package:hive_flutter/screens/statistics_screen.dart';
import 'package:hive_flutter/utils/colors.dart';

import '../screens/add_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/profile_screen.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  // int _page = 0;
  // late PageController pageController;

  // @override
  // void initState() {
  //   super.initState();
  //   pageController = PageController();
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   pageController.dispose();
  // }

  // void navigationTapped(int page) {
  //   pageController.jumpToPage(page);
  // }

  // void onPageChanged(int page) {
  //   setState(() {
  //     _page = page;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          height: 60,
          activeColor: hiveYellow,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.fitness_center_sharp,
                size: 33,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 33,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle,
                size: 33,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_rounded,
                size: 33,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 33,
              ),
            ),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(builder: (context) {
                return const CupertinoPageScaffold(
                  child: FeedScreen(),
                );
              });
            case 1:
              return CupertinoTabView(builder: (context) {
                return const CupertinoPageScaffold(
                  child: SearchScreen(),
                );
              });
            case 2:
              return CupertinoTabView(builder: (context) {
                return const CupertinoPageScaffold(
                  child: AddScreen(),
                );
              });
            case 3:
              return CupertinoTabView(builder: (context) {
                return const CupertinoPageScaffold(
                  child: StatisticsScreen(),
                );
              });
            case 4:
              return CupertinoTabView(builder: (context) {
                return CupertinoPageScaffold(
                  child: ProfileScreen(
                    uid: FirebaseAuth.instance.currentUser!.uid,
                  ),
                );
              });
            default:
              return CupertinoTabView(builder: (context) {
                return const CupertinoPageScaffold(child: FeedScreen());
              });
          }
        },
      ),
    );
  }
}
