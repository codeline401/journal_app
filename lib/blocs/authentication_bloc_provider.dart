import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';

class AuthenticationBlocProvider extends InheritedWidget {

  final AuthenticationBloc authenticationBloc;

  const AuthenticationBlocProvider({super.key, Widget? child, required this.authenticationBloc})
  : super(child: child ?? const SizedBox.shrink());

  static AuthenticationBlocProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthenticationBlocProvider>()!;
  }

  @override 
  bool updateShouldNotify(AuthenticationBlocProvider oldWidget) {
    return authenticationBloc != oldWidget.authenticationBloc;
  }
}