import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tryon_ai/models/feedback_model.dart';
import 'package:tryon_ai/services/analytics_helper.dart';

class FeedbackController with ChangeNotifier {
  int _rating = 0;
  bool _isFollowUp = true;
  bool _sendingFeedbackToServer = false;
  final feedbackTextEditingController = TextEditingController();
  final pageController = PageController();

  int get rating => _rating;

  bool get isFollowUp => _isFollowUp;

  bool get sendingFeedBackToServer => _sendingFeedbackToServer;

  set rating(int rating) {
    if (_rating != rating) {
      _rating = rating;
      notifyListeners();
    }
  }

  set isFollowUp(bool value) {
    if (_isFollowUp != value) {
      _isFollowUp = value;
      notifyListeners();
    }
  }

  String dynamicFeedbackText() {
    if (_rating >= 0 && rating <= 2) {
      return "Sorry for Inconvenience, could you please share your feedback";
    } else {
      return "What is the beautiful thing you like about us?";
    }
  }

  Future<bool> sendFeedBackToServer(
      FeedbackModel feedBackModel, String? token) async {
    if (token == null) return false;
    final dio = Dio();
    try {
      _sendingFeedbackToServer = true;
      notifyListeners();

      // Track feedback submitted event
      AnalyticsHelper.trackFeedbackSubmitted(
        rating: feedBackModel.rating,
        feedback: feedBackModel.feedBackText,
      );

      // If rating is also considered an app rating, track that too
      AnalyticsHelper.trackAppRated(rating: feedBackModel.rating);

      await dio.post(
        'https://1zziv7gfh7.execute-api.ap-south-1.amazonaws.com/dev/feedback',
        data: feedBackModel.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/json',
        ),
      );
      return true;
    } catch (e) {
      _sendingFeedbackToServer = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendReportToServer(String content, String? token) async {
    if (token == null) return false;
    final dio = Dio();
    try {
      _sendingFeedbackToServer = true;
      notifyListeners();
      await dio.post(
        'https://1zziv7gfh7.execute-api.ap-south-1.amazonaws.com/dev/feedback',
        data: {"is_content_reporting": true, "content": content},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'application/json',
        ),
      );
      return true;
    } catch (e) {
      _sendingFeedbackToServer = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _rating = 0;
    _isFollowUp = true;
    feedbackTextEditingController.clear();
    _sendingFeedbackToServer = false;
    notifyListeners();
  }

  @override
  void dispose() {
    feedbackTextEditingController.dispose();
    pageController.dispose();
    super.dispose();
  }
}
