import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final String location;
  final DateTime eventDate;
  final String imageUrl;
  final String category;
  final double latitude; // Add this
  final double longitude; // Add this

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    required this.imageUrl,
    required this.category,
    required this.latitude, // Add this
    required this.longitude, // Add this
  });

  factory Event.fromMap(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(), // Add this
      longitude: (data['longitude'] ?? 0.0).toDouble(), // Add this
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'eventDate': Timestamp.fromDate(eventDate),
      'imageUrl': imageUrl,
      'category': category,
      'latitude': latitude, // Add this
      'longitude': longitude, // Add this
    };
  }
}
