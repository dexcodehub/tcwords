import 'package:flutter/material.dart';
import 'package:tcword/src/views/learning_center_view.dart';
import 'package:tcword/src/views/word_matching_game.dart';
import 'package:tcword/src/views/puzzle_game.dart';
import 'package:tcword/src/views/progress_view.dart';
import 'package:tcword/src/views/parental_control_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    LearningCenterView(),
    WordMatchingGame(),
    PuzzleGame(),
    ProgressView(),
    ParentalControlView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TCWord',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.extension,
                size: 30,
              ),
              label: 'Match',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.games,
                size: 30,
              ),
              label: 'Puzzle',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.analytics,
                size: 30,
              ),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 16,
          unselectedFontSize: 14,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}