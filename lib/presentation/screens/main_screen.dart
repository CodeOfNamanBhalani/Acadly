import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';

import '../controllers/auth_provider.dart';
import '../controllers/timetable_provider.dart';
import '../controllers/assignment_provider.dart';
import '../controllers/exam_provider.dart';
import '../controllers/note_provider.dart';
import '../controllers/notice_provider.dart';

import 'dashboard_screen.dart';
import 'timetable_screen.dart';
import 'assignment_screen.dart';
import 'exam_screen.dart';
import 'notes_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Screens List
  final List<Widget> _screens = const [
    DashboardScreen(),
    TimetableScreen(),
    AssignmentScreen(),
    ExamScreen(),
    NotesScreen(),
    ProfileScreen(),
  ];

  // ----------------------------
  // INIT
  // ----------------------------
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ----------------------------
  // LOAD USER DATA
  // ----------------------------
  void _loadData() {
    final userId = context.read<AuthProvider>().currentUser?.id;

    if (userId != null) {
      context.read<TimetableProvider>().loadTimetable(userId);
      context.read<AssignmentProvider>().loadAssignments(userId);
      context.read<ExamProvider>().loadExams(userId);
      context.read<NoteProvider>().loadNotes(userId);
    }

    // Notices load for everyone
    context.read<NoticeProvider>().loadNotices();
  }

  // ----------------------------
  // UI BUILD
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,

          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textLight,

          selectedFontSize: 12,
          unselectedFontSize: 12,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: "Timetable",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: "Tasks",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined),
              activeIcon: Icon(Icons.quiz),
              label: "Exams",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_outlined),
              activeIcon: Icon(Icons.note),
              label: "Notes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
