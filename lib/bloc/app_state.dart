import 'dart:ui';

import 'package:bloc_image_uploader/auth/auth_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AppState {
  final bool isLoading;
  final AuthError? authError;

  AppState({
    required this.isLoading,
    required this.authError,
  });
}

@immutable
class AppStateLoggedIn extends AppState {
  final User user;
  final Iterable<Reference> images;

  AppStateLoggedIn({
    required super.isLoading,
    required this.images,
    required this.user,
    required super.authError,
  });

  @override
  bool operator ==(other) {
    final otherClass = other;
    if (otherClass is AppStateLoggedIn) {
      return isLoading == otherClass.isLoading &&
          user.uid == otherClass.user.uid &&
          images.length == otherClass.images.length;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hash(user.uid, images);
  @override
  String toString() {
    return 'AppStateLoggedIn, images.length: ${images.length}';
  }
}

@immutable
class AppStateLoggedOut extends AppState {
  AppStateLoggedOut({
    required super.isLoading,
    required super.authError,
  });
  @override
  String toString() {
    return 'AppStateLoggedOut, isLoading: $isLoading , authError: $authError';
  }
}

@immutable
class AppStateIsInRegisterationView extends AppState {
  AppStateIsInRegisterationView({
    required super.isLoading,
    required super.authError,
  });
}

extension GetUser on AppState {
  User? get user {
    final cls = this;
    if (cls is AppStateLoggedIn) {
      return cls.user;
    } else {
      return null;
    }
  }
}

extension GetImages on AppState {
  Iterable<Reference>? get images {
    final cls = this;
    if (cls is AppStateLoggedIn) {
      return cls.images;
    } else {
      return null;
    }
  }
}
