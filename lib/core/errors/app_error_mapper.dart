import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

class AppErrorMessage {
  const AppErrorMessage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

AppErrorMessage mapAppError(Object error) {
  if (error is FirebaseException) {
    final code = error.code;

    if (code == 'permission-denied') {
      return const AppErrorMessage(
        title: 'Access denied',
        subtitle: 'You don\'t have permission to do that.',
      );
    }

    if (code == 'unauthenticated') {
      return const AppErrorMessage(
        title: 'Sign in required',
        subtitle: 'Please sign in and try again.',
      );
    }

    if (code == 'unavailable') {
      return const AppErrorMessage(
        title: 'You\'re offline',
        subtitle: 'Check your connection and try again.',
      );
    }

    if (code == 'not-found') {
      return const AppErrorMessage(
        title: 'Not found',
        subtitle: 'That item no longer exists.',
      );
    }

    if (code == 'failed-precondition') {
      return const AppErrorMessage(
        title: 'Can\'t load right now',
        subtitle: 'Please try again in a moment.',
      );
    }

    return AppErrorMessage(
      title: 'Something went wrong',
      subtitle: error.message?.trim().isNotEmpty == true
          ? error.message!.trim()
          : 'Please try again.',
    );
  }

  if (error is TimeoutException) {
    return const AppErrorMessage(
      title: 'Timed out',
      subtitle: 'That took too long. Please try again.',
    );
  }

  return const AppErrorMessage(
    title: 'Something went wrong',
    subtitle: 'Please try again.',
  );
}
