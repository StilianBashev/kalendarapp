import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<EventModel> events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserEvents();
  }

  void loadUserEvents() async {
    final user = FirebaseServices().currentUser;
    if (user == null) return;
    final result = await EventService().getUserEvents(user.uid);
    setState(() {
      events = result;
      loading = false;
    });
  }

  void confirmDelete(String eventId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Изтрий събитие'),
        content:
            const Text('Сигурни ли сте, че искате да изтриете това събитие?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отказ'),
          ),
          TextButton(
            onPressed: () async {
              await EventService().deleteEvent(eventId);
              Navigator.pop(context);
              loadUserEvents();
            },
            child: const Text(
              'Изтрий',
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  void logoutUser() async {
    await FirebaseServices().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseServices().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Профил')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Име : ${user?.displayName ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Имейл : ${user?.email ?? 'N/A'}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: logoutUser,
              child: const Text('Изход'),
            ),
            const SizedBox(height: 24),
            const Text('Моите събития',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : events.isEmpty
                      ? const Text('Няма създадени събития.')
                      : ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (_, index) {
                            final event = events[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(event.title),
                                subtitle: Text(
                                  '${event.startTime.toLocal()} - ${event.endTime.toLocal()}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => confirmDelete(event.id),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
