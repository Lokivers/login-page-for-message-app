import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? location;
  final String? category;
  bool isLiked;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.location,
    this.category,
    this.isLiked = false,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      category: data['category'],
      isLiked: data['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'category': category,
      'isLiked': isLiked,
    };
  }

  Future<void> toggleLike() async {
    try {
      final firebaseService = FirebaseService.instance();
      final docRef = firebaseService.eventsCollection.doc(id);
      await docRef.update({'isLiked': !isLiked});
      isLiked = !isLiked;
    } catch (e) {
      throw Exception('Failed to toggle like status: $e');
    }
  }

  Future<void> delete() async {
    try {
      final firebaseService = FirebaseService.instance();
      await firebaseService.eventsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}
