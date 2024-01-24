import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';

class JournalEditBlocProvider extends InheritedWidget {
  final JournalEditBloc journalEditBloc;

  const JournalEditBlocProvider({super.key, Widget? child, required this.journalEditBloc}):
    super(child: child ?? const SizedBox.shrink());

  static JournalEditBlocProvider of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<JournalEditBlocProvider>()!;
  }

  @override
  bool updateShouldNotify(JournalEditBlocProvider oldWidget) => false;
}