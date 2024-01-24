import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/classes/format_dates.dart';
import 'package:journal/classes/mood_icons.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore.dart';
//import 'package:journal/services/db_firestore_api.dart';

class EditEntry extends StatefulWidget {
  const EditEntry({super.key});

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {

  late JournalEditBloc _journalEditBloc;
  late FormatDates _formatDates;
  late MoodIcons _moodIcons;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _formatDates = FormatDates();
    _noteController = TextEditingController();
    _noteController.text = '';
    _moodIcons = const MoodIcons(title: 'title', color: Colors.yellow, rotation: 0, icon: Icons.sentiment_very_dissatisfied);

    _journalEditBloc = JournalEditBloc(DbFirestoreService(), add: true, selectedJournal: Journal());
    _journalEditBloc.getJournal();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _journalEditBloc = JournalEditBlocProvider.of(context).journalEditBloc;
  }

  @override
  dispose() {
    _noteController.dispose();
    _journalEditBloc.dispose();
    super.dispose();
  }

  //Date picker
  Future<String> _selectDate(String selectedDate) async {
    DateTime initialDate = DateTime.parse(selectedDate);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      );
    if (pickedDate != null){
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialDate.hour,
        initialDate.minute,
        initialDate.second,
        initialDate.millisecond,
        initialDate.microsecond
      ).toString();
    }

    return selectedDate;
  }

  //The JournalEditBloc receives this request and calls the Clouds Firestore database API
  void _addOrUpdateJournal(){
    _journalEditBloc.saveJournalChanged.add('Save');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entry", style: TextStyle(color: Colors.lightGreen.shade800),),
        automaticallyImplyLeading: false,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.lightGreen.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: _journalEditBloc.dateEdit, 
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(!snapshot.hasData){
                  print('Date is null or not available');
                  return const Text('no data here');

                }
                return ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    String pickerDate = await _selectDate(snapshot.data);
                    _journalEditBloc.dateEditChanged.add(pickerDate);
                  }, 
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 22.0, color: Colors.black,),
                      const SizedBox(width: 16.0,),
                      Text(_formatDates.dateFormatShortMonthDayYear(snapshot.data)),
                      const Icon(Icons.arrow_drop_down, color: Colors.black54,),
                    ],
                  ),
                );
              }
            ),
            StreamBuilder(
              stream: _journalEditBloc.moodEdit, 
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if(!snapshot.hasData){
                  return const Text("No data here");
                }
                return DropdownButtonHideUnderline(
                  child: DropdownButton<MoodIcons>(
                    value: _moodIcons.getMoodIconsList()[
                      _moodIcons.getMoodIconsList().indexWhere((icon) => icon.title == snapshot.data)
                    ],
                    onChanged: (selected){
                      _journalEditBloc.moodEditChanged.add(selected?.title);
                    },
                    items: _moodIcons.getMoodIconsList().map((MoodIcons selected) {
                      return DropdownMenuItem(
                        value: selected,
                        child: Row(
                          children: [
                            Transform(
                              transform: Matrix4.identity()..rotateZ(_moodIcons.getMoodRotation(selected.title)),
                              alignment: Alignment.center,
                              child: Icon(
                                _moodIcons.getMoodIcon(selected.title),
                                color: _moodIcons.getMoodColor(selected.title),
                              ),
                            ),
                            const SizedBox(width: 16.0,),
                            Text(selected.title),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            StreamBuilder(
              stream: _journalEditBloc.noteEdit, 
              builder: ((BuildContext context, AsyncSnapshot snapshot){
                if(!snapshot.hasData){
                  return Container();
                }
                //Use the copyWith to make sure when you edit TextField the cursor does not bounce to the first character
                _noteController.value = _noteController.value.copyWith(text: snapshot.data);
                return Expanded(
                  child: TextField(
                    controller: _noteController,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      icon: Icon(Icons.subject),
                    ),
                    maxLines: null,
                    onChanged: (note) => _journalEditBloc.noteEditChanged.add(note),
                ),
                );
              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, 
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8.0,),
                ElevatedButton(
                  onPressed: () {
                    _addOrUpdateJournal();
                  }, 
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}