import 'package:flutter/material.dart';

class MoodIcons {
  final String title;
  final Color color;
  final double rotation;
  final IconData icon;

  const MoodIcons({required this.title, required this.color, required this.rotation, required this.icon});

  //methode getMood pour sortir un icône
  IconData getMoodIcon(String mood){
    return _moodIconList[_moodIconList.indexWhere((icon) => icon.title == mood)].icon;
  }

  Color getMoodColor(String mood){
    return _moodIconList[_moodIconList.indexWhere((icon) => icon.title == mood)].color;
  }

  double getMoodRotation(String mood){
    return _moodIconList[_moodIconList.indexWhere((icon) => icon.title == mood)].rotation;
  }

  List<MoodIcons> getMoodIconsList() {
    return _moodIconList;
  }
}

//List des icones par défaut comme mood
const List<MoodIcons> _moodIconList = [
  MoodIcons(title: 'Very Satisfied', color: Colors.amber, rotation: 0.4, icon: Icons.sentiment_very_dissatisfied),
  MoodIcons(title: 'Satisfied', color: Colors.green, rotation: 0.2, icon: Icons.sentiment_satisfied),
  MoodIcons(title: 'Neutral', color: Colors.grey, rotation: 0.0, icon: Icons.sentiment_neutral),
  MoodIcons(title: 'Dissatisfied', color: Colors.cyan, rotation: -0.2, icon: Icons.sentiment_dissatisfied),
  MoodIcons(title: 'Very Dissatisfied', color: Colors.red, rotation: -0.4, icon: Icons.sentiment_very_dissatisfied)
];