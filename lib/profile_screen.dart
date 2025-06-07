import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  Future<List<Map>> getMyEvents() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    var snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('startTime')
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Профил')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Имейл: ${user?.email ?? ""}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Изход'),
            ),
            SizedBox(height: 20),
            Text('Моите събития:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map>>(
                future: getMyEvents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var events = snapshot.data!;
                  if (events.isEmpty) {
                    return Text('Нямате събития.');
                  }

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      var event = events[index];
                      return ListTile(
                        title: Text(event['title'] ?? ''),
                        subtitle: Text(event['description'] ?? ''),
                        onTap: () {
                          Navigator.pushNamed(context, '/add_event', arguments: {
                            'eventId': event['id'],
                            'existingData': event,
                          });
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('events')
                                .doc(event['id'])
                                .delete();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => ProfileScreen()),
                            );
                          },
                        ),
                      );
                    },
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
