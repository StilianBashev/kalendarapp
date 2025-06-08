import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import 'event_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<EventModel> _events = [];
  bool _loading = false;
  
  @override
  
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    setState(() => _loading = true);
    final events = await EventService().getEventsByDate(_selectedDay);
    setState(() {
      _events = events;
      _loading = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _loadEvents();
  }

  void _goToEventForm({EventModel? event}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          selectedDate: _selectedDay,
          event: event,
        ),
      ),
    );
    _loadEvents();
  }

  String formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Календар')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarStyle: const CalendarStyle(
              todayDecoration:
                  BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration:
                  BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? const Center(
                        child: Text('Все още няма събития за този ден.'))
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (_, index) {
                          final event = _events[index];
                          return ListTile(
                            title: Text(event.title),
                            subtitle: Text(
                              '${formatTime(event.startTime)} - ${formatTime(event.endTime)}',
                            ),
                            onTap: () => _goToEventForm(event: event),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToEventForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
