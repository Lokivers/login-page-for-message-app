import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventRepository {
  final CollectionReference _eventsCollection = FirebaseFirestore.instance
      .collection('events');

  Future<List<Event>> getEvents() async {
    try {
      final snapshot =
          await _eventsCollection.orderBy('date', descending: false).get();

      return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      await _eventsCollection.add(event.toFirestore());
    } catch (e) {
      throw Exception('Failed to add event: $e');
    }
  }

  Stream<List<Event>> watchEvents() {
    return _eventsCollection
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
  }

  Future<void> uploadEvent(Event event) async {
    try {
      await _eventsCollection.add({
        'title': event.title,
        'description': event.description,
        'date': Timestamp.fromDate(event.date),
        'location': event.location,
        'category': event.category,
        'isLiked': false,
      });
    } catch (e) {
      throw Exception('Failed to upload event: $e');
    }
  }
}
