import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var calendarFormat = CalendarFormat.month;
  var focusedDay = DateTime.now();
  var selectedDay = DateTime.now();
  var events = [];

  @override
  void initState() {
    super.initState();
    fetchEventsFor(selectedDay);
  }

  fetchEventsFor(DateTime day) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var start = DateTime(day.year, day.month, day.day);
    var end = start.add(Duration(days: 1));

    var snap = await FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', isEqualTo: user.uid)
        .where('startTime', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('startTime', isLessThan: end.toIso8601String())
        .orderBy('startTime')
        .get();

    setState(() {
      events = snap.docs.map((x) {
        var d = x.data();
        d['id'] = x.id;
        return d;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Календар')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: focusedDay,
            calendarFormat: calendarFormat,
            selectedDayPredicate: (d) => isSameDay(selectedDay, d),
            onDaySelected: (sel, foc) {
              setState(() {
                selectedDay = sel;
                focusedDay = foc;
              });
              fetchEventsFor(sel);
            },
            onFormatChanged: (f) => setState(() => calendarFormat = f),
            onPageChanged: (f) => focusedDay = f,
          ),
          Expanded(
            child: events.isEmpty
                ? Center(child: Text('Няма събития.'))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, i) {
                      var e = events[i];
                      return ListTile(
                        title: Text(e['title'] ?? ''),
                        subtitle: Text(e['description'] ?? ''),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_event');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
