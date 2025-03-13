import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static bool _initialized = false;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService._()
    : _firestore = FirebaseFirestore.instance,
      _storage = FirebaseStorage.instance;

  static Future<FirebaseService> getInstance() async {
    if (!_initialized) {
      await Firebase.initializeApp();
      _initialized = true;
      _instance = FirebaseService._();
    }
    return _instance!;
  }

  CollectionReference<Map<String, dynamic>> get eventsCollection =>
      _firestore.collection('events');

  Reference get eventsStorageRef => _storage.ref().child('events');

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        rethrow;
      }
    }
  }

  static instance() {}
}
