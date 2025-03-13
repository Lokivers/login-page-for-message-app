import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static String getMessageFromError(dynamic error) {
    if (error is FirebaseException) {
      return error.message ?? 'An unknown Firebase error occurred';
    }
    return error.toString();
  }

  static void showError(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getMessageFromError(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
