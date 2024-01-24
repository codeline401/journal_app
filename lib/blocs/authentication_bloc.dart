import 'dart:async';

import 'package:journal/services/authentication_api.dart';

class AuthenticationBloc {
  late AuthenticationApi authenticationApi;

  final StreamController<String> authenticationController  = StreamController<String>();
  Sink<String> get addUser => authenticationController.sink;
  Stream<String> get user => authenticationController.stream;

  final StreamController<bool> logoutController = StreamController<bool>();
  Sink<bool> get logoutUser => logoutController.sink;
  Stream<bool> get listLogoutUser => logoutController.stream;

  AuthenticationBloc(this.authenticationApi){
    onAuthChanged();
  }

  void dispose() {
    authenticationController.close();
    logoutController.close();
  }

 void onAuthChanged() {
  //Ecoute les changement d'état d'authetification
  authenticationApi.getFirebaseAuth().authStateChanges().listen((user) {
    //Emet l'ID de l'utilsateur à travers le stream
    final String? uid = user?.uid;
    addUser.add(uid ?? ""); //Utilsation de ?? pour traiter le cas où l'ID est null
  });

  logoutController.stream.listen((event) {
    if (event == true) {
      signout();
    }
  });
}


  void signout(){
    authenticationApi.signOut();
  }
}