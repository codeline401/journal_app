import 'package:flutter/material.dart';
import 'package:journal/blocs/home_bloc.dart';

class HomeBolcProvider extends InheritedWidget {

  final HomeBloc homeBloc;
  final String uid;

  const HomeBolcProvider({super.key, Widget? child, required this.homeBloc, required this.uid})
    :super(child: child ?? const SizedBox.shrink());

  static HomeBolcProvider of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<HomeBolcProvider>()!;
  }

  @override
  bool updateShouldNotify(HomeBolcProvider oldWidget){
    return homeBloc != oldWidget.homeBloc;
  }
}