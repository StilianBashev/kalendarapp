import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

class EventFormScreen extends StatefulWidget {
  final DateTime selectedDate;
  final EventModel? event;

  const EventFormScreen({
    required this.selectedDate,
    this.event,
    super.key,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final e = widget.event!;
      title.text = e.title;
      description.text = e.description;
      startDate = e.startTime;
      endDate = e.endTime;
      startTime = TimeOfDay.fromDateTime(e.startTime);
      endTime = TimeOfDay.fromDateTime(e.endTime);
    } else {
      startDate = widget.selectedDate;
      endDate = widget.selectedDate;
      startTime = const TimeOfDay(hour: 9, minute: 0);
      endTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  void pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate! : endDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime! : endTime!,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  DateTime combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final start = combine(startDate!, startTime!);
    final end = combine(endDate!, endTime!);

    final data = {
      'title': title.text.trim(),
      'description': description.text.trim(),
      'startTime': start.toIso8601String(),
      'endTime': end.toIso8601String(),
      'createdBy': user.uid,
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      if (widget.event == null) {
        await EventService().addEvent(EventModel(
          id: '',
          title: data['title']!,
          description: data['description']!,
          startTime: start,
          endTime: end,
          createdBy: data['createdBy']!,
          createdAt: DateTime.now(),
        ));
      } else {
        await EventService().updateEvent(widget.event!.id, data);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Грешка ;( Моля, опитайте отново.')),
      );
    }
  }

  String formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;

    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? 'Редактирай събитие' : 'Ново събитие')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: title,
                label: 'Заглавие',
                validator: Validators.validateNotEmpty,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: description,
                label: 'Описание',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => pickDate(true),
                      child: Text('Начална дата: ${formatDate(startDate!)}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => pickTime(true),
                      child: Text('Време: ${formatTime(startTime!)}'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => pickDate(false),
                      child: Text('Крайна дата: ${formatDate(endDate!)}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => pickTime(false),
                      child: Text('Време: ${formatTime(endTime!)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveEvent,
                child: Text(isEdit ? 'Редактирай' : 'Запази промените'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
