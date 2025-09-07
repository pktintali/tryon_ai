import 'dart:convert';

class FeedbackModel {
  const FeedbackModel({
    required this.feedBackText,
    required this.isFollowUp,
    required this.rating,
    required this.username,
  });
  final int rating;
  final bool isFollowUp;
  final String feedBackText;
  final String username;

  Map<String, dynamic> toMap() {
    return {
      'userName': username,
      'rating': rating,
      'feedback': feedBackText,
      'canFollowUp': isFollowUp
    };
  }

  String toJson() => jsonEncode(toMap());
}
