import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_register_ui/env.dart';
import 'package:flutter_login_register_ui/screens/manageUser/screen_user.dart';
import '../screens/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class GuruScreen extends StatefulWidget {
  @override
  int currentTab = 0;
  Widget currentScreen;
  GuruScreen({this.currentTab,this.currentScreen});
  _GuruScreenState createState() => _GuruScreenState();
}

class _GuruScreenState extends State<GuruScreen> {
  // Properties & Variables needed
  int currentTab = 0;
  int siswa;
  int guru;
  int matpel;
  Widget currentScreen;
  void initState() {
    checkLogin();
    super.initState();
    currentTab = (widget.currentTab != null) ? widget.currentTab : 0 ;
    currentScreen = (widget.currentScreen != null) ? widget.currentScreen : Dashboard();
  }

  

  void logout() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove("token");
    pref.remove("akses");
    pref.remove("email");
    pref.remove("nama");
    pref.remove("kode_login");
    pref.remove("ta");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => WelcomePage()
    ), (route) => false);
  }

  void checkLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getString('token') == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => WelcomePage()
      ), (route) => false);
    }
  }
 // to keep track of active tab index
  final List<Widget> screens = [
    Dashboard(),
  ]; // to store nested tabs
  final PageStorageBucket bucket = PageStorageBucket();

  
  DateTime currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || 
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      return Future.value(false);
    }
    pop();
  }

  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: PageStorage(
          child: currentScreen,
          bucket: bucket,
        ),
        onWillPop: onWillPop
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.note_add_sharp),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => NilaiView()
      ), (route) => false);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          // color: Colors.black54,
          notchMargin: 10,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          currentScreen =
                              Dashboard(); // if user taps on this dashboard tab will be active
                          currentTab = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.dashboard,
                            color: currentTab == 0 ? Colors.pinkAccent: Colors.grey,
                          ),
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              color: currentTab == 0 ? Colors.pinkAccent: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          currentScreen = SiswaOnlyView();
                              // Chat(); // if user taps on this dashboard tab will be active
                          currentTab = 1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.supervised_user_circle_sharp,
                            color: currentTab == 1 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            'Siswa',
                            style: TextStyle(
                              color: currentTab == 1 ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                // Right Tab bar icons

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          Navigator.push(context,CupertinoPageRoute(builder: (context) => OnlyViewMatpel()));
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.book,
                            color: currentTab == 2 ? Colors.greenAccent : Colors.grey,
                          ),
                          Text(
                            'Pelajaran',
                            style: TextStyle(
                              color: currentTab == 2 ? Colors.greenAccent : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 40,
                      onPressed: () {
                        logout();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.exit_to_app_outlined,
                            color: currentTab == 3 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            'Keluar',
                            style: TextStyle(
                              color: currentTab == 3 ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )

              ],
            ),
          ),
        ), 
    );
  }
}
