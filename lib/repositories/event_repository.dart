import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  Future<void> addEvent(Event event, {File? image}) async {
    String? imageUrl;
    if (image != null) {
      imageUrl = await uploadImage(image);
    }

    await _firestore.collection('events').add({
      ...event.toMap(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
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
        'imageUrl': event.imageUrl,
        'isLiked': false,
      });
    } catch (e) {
      throw Exception('Failed to upload event: $e');
    }
  }

  Future<String> uploadImage(File image) async {
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference ref = _storage.ref().child('event_images/$fileName');
    final UploadTask uploadTask = ref.putFile(image);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}
