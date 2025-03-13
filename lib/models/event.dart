import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
  String get formattedTime => DateFormat('hh:mm a').format(date);
  String get fullFormattedDate =>
      DateFormat('EEEE, MMM dd, yyyy - hh:mm a').format(date);

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime eventDate;
    try {
      eventDate =
          data['date'] is Timestamp
              ? (data['date'] as Timestamp).toDate()
              : DateTime.parse(data['date'].toString());
    } catch (e) {
      eventDate = DateTime.now(); // Fallback to current date if parsing fails
    }

    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: eventDate,
      location: data['location'],
      category: data['category'],
      isLiked: data['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date':
          date, // Firestore will automatically convert DateTime to Timestamp
      'location': location,
      'category': category,
      'isLiked': isLiked,
    };
  }

  Future<void> toggleLike() async {
    try {
      final firebaseService = await FirebaseService.getInstance();
      final docRef = firebaseService.eventsCollection.doc(id);
      await docRef.update({'isLiked': !isLiked});
      isLiked = !isLiked;
    } catch (e) {
      throw Exception('Failed to toggle like status: $e');
    }
  }

  Future<void> updateDate(DateTime newDate) async {
    try {
      final firebaseService = await FirebaseService.getInstance();
      final docRef = firebaseService.eventsCollection.doc(id);
      await docRef.update({'date': Timestamp.fromDate(newDate)});
    } catch (e) {
      throw Exception('Failed to update event date: $e');
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

  bool isUpcoming() {
    return date.isAfter(DateTime.now());
  }

  bool isOnSameDay(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}
