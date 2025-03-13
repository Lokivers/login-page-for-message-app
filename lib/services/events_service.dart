import 'package:flutter/material.dart';
import 'firebase_service.dart';

class EventsService {
  static Future<void> likeEvent(
    BuildContext context,
    String eventId,
    String userId,
  ) async {
    try {
      final firebaseService = await FirebaseService.getInstance();
      await firebaseService.toggleLike(eventId, userId);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Like updated successfully')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like: ${e.toString()}')),
      );
    }
  }

  static Future<bool> deleteEvent(BuildContext context, String eventId) async {
    try {
      final firebaseService = await FirebaseService.getInstance();
      await firebaseService.deleteEvent(eventId);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
      return true;
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: ${e.toString()}')),
      );
      return false;
    }
  }
}
