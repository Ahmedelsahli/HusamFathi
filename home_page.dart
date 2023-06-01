import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostepil1200/user_data_page.dart';
import 'account_page.dart';
import 'alert_diaalog.dart';
import 'main_page.dart';
import 'reverstion_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    checkUserData();
    super.initState();
  }

  /// Check If Document Exists
  Future<void> checkUserData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userID = FirebaseAuth.instance.currentUser!.uid;
      var collectionRef = firestore.collection('users');
      var doc = await collectionRef.doc(userID).get();
      if (doc.exists == false) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserDataPage(
                    birthdate: '',
                    days: [],
                    doctorCode: '',
                    name: '',
                    gander: '',
                    speciality: '',
                  )),
        );
      }
    } catch (e) {
      log(e.toString());
      showAlertDialog(
          'خطا في الاتصال', "الرجاء التحقق من اتصالك بالانترنت", context);
    }
  }

  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MainPage(),
    ReverstionPage(),
    AccountPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'الرئيسي',
            ),
            NavigationDestination(
              icon: Icon(Icons.list),
              label: 'حجوزاتي',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_box),
              label: 'حسابي',
            ),
          ],
          selectedIndex: _selectedIndex,
          // selectedItemColor: Colors.amber[800],
          onDestinationSelected: _onItemTapped,
        ),
      ),
    );
  }
}
