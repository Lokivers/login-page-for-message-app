class Event {
  final String? id;
  final String title;
  final String imageUrl;
  final String description;
  final DateTime eventDate;
  final String location;
  final String category;

  Event({
    this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.eventDate,
    required this.location,
    required this.category,
  });
}
