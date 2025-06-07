import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventFormScreen extends StatefulWidget {
  final String? eventId;
  final Map<String, dynamic>? existingData;

  EventFormScreen({this.eventId, this.existingData});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  var title = TextEditingController();
  var desc = TextEditingController();
  DateTime? date;
  TimeOfDay? start;
  TimeOfDay? end;

  @override
  void initState() {
    super.initState();
    var data = widget.existingData;
    if (data != null) {
      title.text = data['title'] ?? '';
      desc.text = data['description'] ?? '';
      var s = DateTime.tryParse(data['startTime'] ?? '');
      var e = DateTime.tryParse(data['endTime'] ?? '');
      if (s != null) {
        date = DateTime(s.year, s.month, s.day);
        start = TimeOfDay.fromDateTime(s);
      }
      if (e != null) end = TimeOfDay.fromDateTime(e);
    }
  }

  pickDate() async {
    var picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => date = picked);
  }

  pickTime(bool isStart) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) start = picked;
        else end = picked;
      });
    }
  }

  saveEvent() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null || date == null || start == null || end == null) return;

    var startDT = DateTime(date!.year, date!.month, date!.day, start!.hour, start!.minute);
    var endDT = DateTime(date!.year, date!.month, date!.day, end!.hour, end!.minute);

    var data = {
      'title': title.text,
      'description': desc.text,
      'startTime': startDT.toIso8601String(),
      'endTime': endDT.toIso8601String(),
      'createdBy': user.uid,
      'createdAt': DateTime.now().toIso8601String(),
    };

    var col = FirebaseFirestore.instance.collection('events');
    if (widget.eventId != null) {
      await col.doc(widget.eventId).update(data);
    } else {
      await col.add(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var editing = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Редактирай събитие' : 'Ново събитие')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: 'Заглавие'),
            ),
            TextField(
              controller: desc,
              decoration: InputDecoration(labelText: 'Описание'),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(date == null
                  ? 'Избери дата'
                  : 'Дата: ${date!.year}-${date!.month}-${date!.day}'),
              trailing: Icon(Icons.calendar_today),
              onTap: pickDate,
            ),
            ListTile(
              title: Text(start == null
                  ? 'Избери начален час'
                  : 'Начало: ${start!.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () => pickTime(true),
            ),
            ListTile(
              title: Text(end == null
                  ? 'Избери краен час'
                  : 'Край: ${end!.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () => pickTime(false),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveEvent,
              child: Text(editing ? 'Запази' : 'Добави'),
            ),
          ],
        ),
      ),
    );
  }
}
