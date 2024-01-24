import 'package:flutter/material.dart';
import 'package:journal/pages/home.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/services/authentication.dart';
import 'package:journal/services/db_firestore.dart';
import 'package:journal/pages/login.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final AutheticationService autheticationService = AutheticationService();
    final AuthenticationBloc authenticationBloc = AuthenticationBloc(autheticationService);

    return AuthenticationBlocProvider(
      authenticationBloc: authenticationBloc,
      child: StreamBuilder(
        initialData: null,
        stream: authenticationBloc.user, 
        builder: ((BuildContext context, AsyncSnapshot snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Container(
              color: Colors.lightGreen,
              child: const CircularProgressIndicator(),
            );
          }
          else if (snapshot.hasData) {
            return HomeBolcProvider(
              homeBloc: HomeBloc(DbFirestoreService(), AutheticationService()), 
              uid: snapshot.data,
              child: _buildMaterialApp(home: const Home()),
            );
          }
          else {
            return _buildMaterialApp(home: const Login());
          }
        }),
      ),
    );
  }

  MaterialApp _buildMaterialApp({required Widget? home}) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Journal',
    theme: ThemeData(
      primarySwatch: Colors.lightGreen,
      canvasColor: Colors.lightGreen.shade50,
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.lightGreen,
      ),
    ),
    home: home,
  );
  }
}