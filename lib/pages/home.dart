import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/classes/format_dates.dart';
import 'package:journal/classes/mood_icons.dart';
import 'package:journal/models/journal.dart';
//import 'package:journal/pages/login.dart';
import 'package:journal/pages/edit_entry.dart';
import 'package:journal/services/db_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late AuthenticationBloc _authenticationBloc;
  late HomeBloc _homeBloc;
  late String _uid;
  late MoodIcons _moodIcons;
  late FormatDates _formatDates;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationBloc = AuthenticationBlocProvider.of(context).authenticationBloc;
    _homeBloc = HomeBolcProvider.of(context).homeBloc;
    _uid = HomeBolcProvider.of(context).uid;
  }

  @override
  void dispose(){
    _homeBloc.dispose();
    super.dispose();
  }

  //Add or Edit Journal Entry and call the show Entry Dialog
  void _addOrEditJournal({bool? add, Journal? journal}) {
    Navigator.push(context, 
      MaterialPageRoute(
        builder: (BuildContext context) => JournalEditBlocProvider(
          journalEditBloc: JournalEditBloc(DbFirestoreService(), add: add!, selectedJournal: journal!),
          child: const EditEntry(),
        ),
        fullscreenDialog: true,
      ));
  }

  //COnfirm a deleting Journal Entry
  Future<bool> _confirmDeletejournal() async {
    return await showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Journal'),
          content: const Text('Are you sure you would like to delete ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              }, 
              child: const Text("Cancel")
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              }, 
              child: const Text("DELETE", style: TextStyle(color: Colors.red),),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Journal', style: TextStyle(color: Colors.lightGreen.shade800),)),
        elevation: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42.0), 
          child: Container(),
          ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.lightGreen.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              //The logout method
              _authenticationBloc.logoutUser.add(true);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _homeBloc.listJournal,
        builder: ((BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData){
            return _buildListViewSeparated(snapshot);
          } else {
            return const Center(
                child: Text('Add journals'),
              );
          }
        }),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen.shade50, Colors.lightGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        backgroundColor: Colors.lightGreen.shade300,
        onPressed: () {
          // Add _addOrEditJournalEntry
          _addOrEditJournal(add: true, journal: Journal(uid: _uid));
        },
        child: const Icon(Icons.add),
        ),
    );
  }

  Widget _buildListViewSeparated(AsyncSnapshot snapshot){
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        String titleDate = _formatDates.dateFormatShortMonthDayYear(snapshot.data[index].date);
        String subtitle = snapshot.data[index].mood + "\n" + snapshot.data[index].note;

        return Dismissible(
          key: Key(snapshot.data[index].docummentID),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left : 16.0),
            child: const Icon(Icons.delete, color: Colors.white,),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(Icons.delete, color: Colors.white,),
          ),
          child:  ListTile(
            leading: Column(
              children: [
                Text(_formatDates.dateFormatDayNumber(snapshot.data[index].date), style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                  color: Colors.lightGreen,
                ),
                ),
                Text(_formatDates.dateFormatShortDayName(snapshot.data[index].date),
                ),
              ],
            ),
            trailing: Transform(
              transform: Matrix4.identity()..rotateZ(_moodIcons.getMoodRotation(snapshot.data[index].mood)),
              alignment: Alignment.center,
              child: Icon(_moodIcons.getMoodIcon(snapshot.data[index].mood), color: 
                _moodIcons.getMoodColor(snapshot.data[index].mood), size: 42.0,
                ),
            ),
            title: Text(titleDate,
              style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            subtitle: Text(subtitle),
            onTap: () {
              _addOrEditJournal(
                add: false,
                journal: snapshot.data[index],
              );
            },
          ),
          confirmDismiss: (direction) async {
            bool confirmDelete = await _confirmDeletejournal();
            if(confirmDelete){
              _homeBloc.deleteJournal.add(snapshot.data[index]);
            }
            return null;
          },
        );
      }, 
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          color: Colors.grey,
        );
      }, 
      itemCount: snapshot.data.length,
    );
  }
}