import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'HomeScreen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  Future<bool> loginPhone(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 120),
      verificationCompleted: (AuthCredential credential) async {
        Navigator.of(context).pop();
        AuthResult result = await _auth.signInWithCredential(credential);
        FirebaseUser user = result.user;
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                user: user,
              ),
            ),
          );
        }
      },
      verificationFailed: (AuthException exception) {
        FlutterToast(context).showToast(
          child: Text('Error occured {$exception}'),
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 30),
        );
      },
      codeSent: (String verficationId, [int forceResendingToken]) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Give a code: '),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _codeController,
                    ),
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Confirm'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () async {
                      AuthCredential credential =
                          PhoneAuthProvider.getCredential(
                        verificationId: verficationId,
                        smsCode: _codeController.text.trim(),
                      );
                      print(credential);
                      AuthResult result =
                          await _auth.signInWithCredential(credential);
                      FirebaseUser user = result.user;

                      if (user != null) {
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            user: user,
                          ),
                        );
                        } else {
                          print('Error');
                        }
                      },
                  )
                ]
              );
            },);
      },
      codeAutoRetrievalTimeout: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(32),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Login",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 36,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "Mobile Number"),
                controller: _phoneController,
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("LOGIN"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    loginPhone(_phoneController.text.trim(), context);
                  },
                  color: Colors.blue,
                ),
              )
            ],
          ),
        ),
      ),
    ),
    );
  }
}
