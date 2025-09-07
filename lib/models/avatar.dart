import 'dart:io';

/// User avatar model wrapping a stored image file.
class Avatar {
  final File imageFile;
  final DateTime createdAt;

  Avatar({required this.imageFile, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();
}
