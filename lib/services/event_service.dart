import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final CollectionReference events = FirebaseFirestore.instance.collection('events');

  Future<void> addEvent(EventModel event) async {
    try {
      await events.add(event.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await events.doc(eventId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await events.doc(eventId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getUserEvents(String uid) async {
    try {
      final snapshot = await events.where('createdBy', isEqualTo: uid).get();
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getEventsByDate(DateTime date) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      final snapshot = await events
          .where('startTime', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('startTime', isLessThan: end.toIso8601String())
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<EventModel?> getEventById(String id) async {
    try {
      final doc = await events.doc(id).get();
      if (doc.exists) {
        return EventModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
