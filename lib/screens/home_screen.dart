import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parcial_final/components/loader_component.dart';
import 'package:email_validator/email_validator.dart';
import 'package:parcial_final/helpers/constans.dart';
import 'package:parcial_final/models/response.dart';
import 'package:parcial_final/models/token.dart';
import 'package:parcial_final/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parcial_final/models/response.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _email = '';
  String _gusto = '';
  String _noGusto = '';
  String _comentarios = '';
  int _estrellas = 0;

  bool _emailShowError = false;
  String _emailError = '';

  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _getForm(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cuestionario De satisfacción.'),
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
                  _getBody(),
                  SizedBox(
                    height: 20,
                  ),
                  _showEmail(),
                  _showGusto(),
                  _showNoGusto(),
                  _showComentarios(),
                  _showEstrellas(),
                  _showButtons(),
                ],
              ),
            ),
            _showLoader
                ? LoaderComponent(text: 'Por favor espere...')
                : Container(),
          ],
        ));
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                'Bienvenid@ ${widget.token.user.fullName}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'Ingresa tu email...',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.alternate_email),
          suffixIcon: Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showGusto() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'Que fue lo que mas te gusto?',
          labelText: 'Que fue lo que mas te gusto?',
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.agriculture),
          suffixIcon: Icon(Icons.accessibility),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _gusto = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _showSaveButton(),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showSaveButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Guardar Respuesta'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFF120E43);
          }),
        ),
        onPressed: () => postForm(widget.token),
      ),
    );
  }

  Widget _showNoGusto() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'Que fue lo que NO te gusto?',
          labelText: 'Que NO te gusto?',
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.access_alarm_outlined),
          suffixIcon: Icon(Icons.access_alarm),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _noGusto = value;
        },
      ),
    );
  }

  Widget _showComentarios() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'tienes algun comentario?',
          labelText: 'Comentarios adicionales',
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.access_alarm_outlined),
          suffixIcon: Icon(Icons.access_alarm),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _comentarios = value;
        },
      ),
    );
  }

  Widget _showEstrellas() {
    return RatingBar.builder(
      initialRating: 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 15.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        _estrellas = rating.toInt();
      },
    );
  }

  bool _validToken(Token token) {
    if (DateTime.parse(token.expiration).isAfter(DateTime.now())) {
      return true;
    }

    return false;
  }

  Future<Null> _getForm(Token token) async {
    Response response = await getForm(token);
    print("Respuesta del metodo GET: $response");
  }

  Future<Response> getForm(Token token) async {
    if (!_validToken(token)) {
      return Response(
          isSuccess: false,
          message:
              'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }

    var url = Uri.parse('${Constans.apiUrl}/api/Finals');
    var response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );
    var body = response.body;
    print(body);
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }
    var decodedJson = jsonDecode(body);
    return Response(isSuccess: true, result: decodedJson);
  }

  bool _validateFields() {
    bool isValid = true;

    if (_email.isEmpty) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar tu email.';
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email válido.';
    } else {
      _emailShowError = false;
    }
    setState(() {});
    return isValid;
  }

  void postForm(Token token) async {
    if (!_validateFields()) {
      return;
    }

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estes conectado a internet.',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'email': _email,
      'qualification': _estrellas,
      'theBest': _gusto,
      'theWorst': _noGusto,
      'remarks': _comentarios,
    };

    var url = Uri.parse('${Constans.apiUrl}/api/Finals');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}'
      },
      body: jsonEncode(request),
    );
    print(request);
    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      print(
          "error al consumir el metodo POST" + response.statusCode.toString());
      return;
    }

    var body = response.body;
    var decodedJson = jsonDecode(body);
    print(decodedJson);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
