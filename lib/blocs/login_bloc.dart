// ignore_for_file: avoid_print

import 'dart:async';
import 'package:journal/classes/validators.dart';
import 'package:journal/services/authentication_api.dart';

class LoginBloc with Validators {
  late final AuthenticationApi authenticationApi;
  late String _email;
  late String _password;
  late bool _emailValid;
  late bool _passwordValid;

  final StreamController<String> emailController = StreamController<String>.broadcast();
  Sink<String> get emailChanged => emailController.sink;
  Stream<String> get email => emailController.stream.transform(validateEmail);

  final StreamController<String> passwordController = StreamController<String>.broadcast();
  Sink<String> get passwordChanged => passwordController.sink;
  Stream<String> get password => passwordController.stream.transform(validatePassword);

  final StreamController<bool> enableLoginCreateButtonController = StreamController<bool>.broadcast();
  Sink<bool> get enableLoginCreateButtonChanged => enableLoginCreateButtonController.sink;
  Stream<bool> get enableLoginCreateButton => enableLoginCreateButtonController.stream;

  final StreamController<String> loginOrCreateButtonController = StreamController<String>();
  Sink<String> get loginOrCreateButtonChanged => loginOrCreateButtonController.sink;
  Stream<String> get loginOrCreateButton => loginOrCreateButtonController.stream;

  final StreamController<String> loginOrCreateController = StreamController<String>();
  Sink<String> get loginOrCreateChanged => loginOrCreateController.sink;
  Stream<String> get loginOrCreate => loginOrCreateController.stream;

  LoginBloc(this.authenticationApi){
    startListenerIfEmailPasswordAreValid();
  }

  void dispose() {
    passwordController.close();
    emailController.close();
    enableLoginCreateButtonController.close();
    loginOrCreateButtonController.close();
    loginOrCreateController.close();
  }

  void startListenerIfEmailPasswordAreValid() {
    email.listen((event) { 
      _email = event;
      _emailValid = true;
      updateEnableLoginCreateButtonStream();
    }).onError((handleError){
      _email ='';
      _emailValid = false;
      updateEnableLoginCreateButtonStream();
    });

    password.listen((event) { 
      _password = event;
      _passwordValid = true;
      updateEnableLoginCreateButtonStream();
    }).onError((handleError){
      _password = '';
      _passwordValid = false;
      updateEnableLoginCreateButtonStream();
    });

    loginOrCreate.listen((event) { 
      event == 'Loging' ? logIn() : createAccount();
    });
  }

  void updateEnableLoginCreateButtonStream(){
    enableLoginCreateButtonChanged.add(_emailValid && _passwordValid);
  }

  Future<String> logIn() async {
    if(_emailValid && _passwordValid){
      try {
        await authenticationApi.signInWithEmailAndPassword(email: _email, password: _password);
        return 'Success';
      } catch (e) {
        print('Login error : $e');
        return e.toString();
      }
    } else {
      return 'Email and password are not valid';
    }
  }

  Future<String> createAccount() async {
    if(_emailValid && _passwordValid){
      try {
        await authenticationApi.createUserWithEmailAndPassword(email: _email, password: _password);
        await authenticationApi.signInWithEmailAndPassword(email: _email, password: _password);

        return 'Created user successfully';
      } catch (error) {
        print('Error creating user : $error');
        return error.toString();
      }
    } else {
      return 'Error creating user';
    }
  }
}