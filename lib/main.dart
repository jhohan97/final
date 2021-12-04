import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:parcial_final/screens/home_screen.dart';
import 'package:parcial_final/screens/login_screen.dart';
import 'package:parcial_final/screens/wait_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/token.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _showLoginPage = true;
  late Token _token;

  @override
  void initState() {
    super.initState();
    _getHome();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Examen final App',
      home: _isLoading
          ? WaitScreen()
          : _showLoginPage
              ? LoginScreen()
              : HomeScreen(token: _token),
    );
  }

  void _getHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRemembered = prefs.getBool('isRemembered') ?? false;
    if (isRemembered) {
      String? userBody = prefs.getString('userBody');
      if (userBody != null) {
        var decodedJson = jsonDecode(userBody);
        _token = Token.fromJson(decodedJson);
        if (DateTime.parse(_token.expiration).isAfter(DateTime.now())) {
          _showLoginPage = false;
        }
      }
    }

    _isLoading = false;
    setState(() {});
  }
}
