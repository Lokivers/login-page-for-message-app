import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../services/firebase_service.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  Future<List<Event>> getEvents() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('events')
              .orderBy('eventDate', descending: false)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event(
          id: doc.id, // Add id to map the document ID
          title: data['title'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          eventDate: (data['eventDate'] as Timestamp).toDate(),
          location: data['location'] ?? '',
          category: data['category'] ?? '',
          latitude: data['latitude'] ?? 0.0,
          longitude: data['longitude'] ?? 0.0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> uploadEvent(Event event) async {
    try {
      await _firestore.collection('events').add({
        'title': event.title,
        'imageUrl': event.imageUrl,
        'description': event.description,
        'eventDate': Timestamp.fromDate(event.eventDate),
        'location': event.location,
        'category': event.category,
      });
    } catch (e) {
      throw Exception('Failed to upload event');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event');
    }
  }
}
