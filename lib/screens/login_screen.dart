import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:parcial_final/helpers/constans.dart';
import 'package:parcial_final/models/token.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _showFBButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showFBButton() {
    return Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton.icon(
                onPressed: () => _loginFb(),
                icon: FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.white,
                ),
                label: Text('Iniciar sesión con Facebook'),
                style: ElevatedButton.styleFrom(
                    primary: Color(0xFF3B5998), onPrimary: Colors.white)))
      ],
    );
  }

  void _loginFb() async {
    await FacebookAuth.i.logOut();
    var result = await FacebookAuth.i.login(
      permissions: ["public_profile", "email"],
    );

    if (result.status == LoginStatus.success) {
      final requestData = await FacebookAuth.i.getUserData(
        fields:
            "email, name, picture.width(800).heigth(800), first_name, last_name",
      );

      var picture = requestData['picture'];
      var data = picture['data'];

      Map<String, dynamic> request = {
        'email': requestData['email'],
        'id': requestData['id'],
        'loginType': 2,
        'fullName': requestData['name'],
        'photoURL': data['url'],
        'firtsName': requestData['first_name'],
        'lastName': requestData['last_name'],
      };
      await _socialLogin(request);
    }
  }

  Future _socialLogin(Map<String, dynamic> request) async {
    var url = Uri.parse('${Constans.apiUrl}/api/Account/SocialLogin');
    var bodyRequest = jsonEncode(request);
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: bodyRequest,
    );

    var body = response.body;
    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  token: token,
                )));
  }
}
