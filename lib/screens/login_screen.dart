import 'package:flutter/material.dart';
import '../shared/authentication.dart';
import 'excel_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  String _userId = "";
  String email = "";
  List<String?> userList = [];
  final String _password = "";
  final String _email = "";
  String _message = "";
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  late Authentication auth;

  @override
  void initState() {
    auth = Authentication();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.zero,
                  child: Image.asset('icons/icon.png',
                    width: 150.0, height: 150.0,) ),
              emailInput(),
              passwordInput(),
              mainButton(),
              secondaryButton(),
              validationMessage(),
            ],),),),),
    );
  }

  Widget emailInput() {
    return Padding(
        padding: const EdgeInsets.only(top:50),
        child: TextFormField(
            controller: txtEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                hintText: 'email',
                icon: Icon(Icons.mail)
            ),
            validator: (text) {
              if(text != null){
                text.isEmpty ? 'Email is required' : '';
              }
              return null;
            }        )
    );
  }

  Widget passwordInput() {
    return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: TextFormField(
            controller: txtPassword,
            keyboardType: TextInputType.emailAddress,
            obscureText: true,
            decoration: const InputDecoration(
                hintText: 'password',
                icon: Icon(Icons.enhanced_encryption)
            ),
            validator: (text) {
              if(text != null){
                text.isEmpty ? 'Password is required' : '';
              }
              return null;
            }



          //=> text.isEmpty ? 'Password is required' : null,
        )
    );
  }

  Widget mainButton() {
    String buttonText = _isLogin ? 'Login' : 'Sign up';
    return Padding(
        padding: const EdgeInsets.only(top: 100),
        child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
                elevation: 3,
              ),
              child: Text(buttonText),
              onPressed: submit,
            )
        )
    );
  }

  Future submit() async {

    setState(() {
    });
    try {
      if (_isLogin) {
        userList = (await auth.login(txtEmail.text, txtPassword.text));
        print('Login for user ${userList[0]}');
      }
      else {
        userList = (await auth.signUp(txtEmail.text, txtPassword.text))!;
        print('Sign up for user ${userList[0]}');
      }
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExcelScreen(userList))
      );
    } catch (e) {

      print('Error: $e');
      setState(() {
        _message = e.toString();
        //_message = e.message;
      });
    }
  }


  Widget secondaryButton() {
    String buttonText = !_isLogin ? 'Login' : 'Sign up';
    return TextButton(
      child: Text(buttonText),
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
    );
  }

  Widget validationMessage() {
    return Text(_message,
      style: const TextStyle(
          fontSize: 14,
          color: Colors.red,
          fontWeight: FontWeight.bold
      ),
    );
  }
}