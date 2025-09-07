import 'package:tryon_ai/services/service_locator.dart';
import 'package:tryon_ai/utils/analytics_events.dart';

/// Helper class to easily track analytics events throughout the app.
class AnalyticsHelper {
  /// Track sign in event with optional properties
  static void trackSignIn({String? method}) {
    Map<String, dynamic> properties = {};
    if (method != null) {
      properties['method'] = method;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.signIn,
          properties: properties,
        );
  }

  /// Track sign up event with optional properties
  static void trackSignUp({String? method}) {
    Map<String, dynamic> properties = {};
    if (method != null) {
      properties['method'] = method;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.signUp,
          properties: properties,
        );
  }

  /// Track sign out event
  static void trackSignOut() {
    ServiceLocator().analyticsService.trackEvent(AnalyticsEvents.signOut);
  }

  /// Track screen view event
  static void trackScreenView(String screenName) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.screenView,
      properties: {'screen_name': screenName},
    );
  }

  /// Identify a user with their unique ID
  static void identifyUser(String userId) {
    ServiceLocator().analyticsService.identify(userId);
  }

  /// Set user properties
  static void setUserProperties(Map<String, dynamic> properties) {
    ServiceLocator().analyticsService.setUserProperties(properties);
  }

  /// Reset user tracking (call on logout)
  static void resetUser() {
    ServiceLocator().analyticsService.reset();
  }

  /// Track when content is reported by users
  static void trackContentReported(String contentType, {String? reason}) {
    Map<String, dynamic> properties = {
      'content_type': contentType,
    };
    if (reason != null) {
      properties['reason'] = reason;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.contentReported,
          properties: properties,
        );
  }

  /// Track AI generation errors
  static void trackAiGenerationError(
      {required String query, required String errorMessage}) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.aiGenerationError,
      properties: {
        'query': query,
        'error_message': errorMessage,
      },
    );
  }

  /// Track network errors
  static void trackNetworkError(
      {required String endpoint, required String errorMessage}) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.networkError,
      properties: {
        'endpoint': endpoint,
        'error_message': errorMessage,
      },
    );
  }

  /// Track when bot is selected (from dropdown or automatically)
  static void trackBotSelected(
      {required String botName, required bool isAutoDetected}) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.botSelected,
      properties: {
        'bot_name': botName,
        'is_auto_detected': isAutoDetected,
      },
    );
  }

  /// Track when user credits are updated
  static void trackCreditsUpdated(
      {required int newCreditAmount, required String reason}) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.creditsUpdated,
      properties: {
        'new_credit_amount': newCreditAmount,
        'reason': reason,
      },
    );
  }

  /// Track when user submits a query to any bot
  static void trackBotQuerySubmitted({
    required String botName,
    required String query,
    String? queryCategory,
  }) {
    Map<String, dynamic> properties = {
      'bot_name': botName,
      'query': query,
    };
    if (queryCategory != null) {
      properties['query_category'] = queryCategory;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.botQuerySubmitted,
          properties: properties,
        );
  }

  /// Track when a bot response is received
  static void trackBotResponseReceived({
    required String botName,
    required String query,
    required int responseTimeMs,
    required bool isSuccess,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.botResponseReceived,
      properties: {
        'bot_name': botName,
        'query': query,
        'response_time_ms': responseTimeMs,
        'is_success': isSuccess,
      },
    );
  }

  /// Track when bot content is expanded (e.g., user taps to see more details)
  static void trackBotContentExpanded({
    required String botName,
    required String contentType,
    String? itemTitle,
  }) {
    Map<String, dynamic> properties = {
      'bot_name': botName,
      'content_type': contentType,
    };
    if (itemTitle != null) {
      properties['item_title'] = itemTitle;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.botContentExpanded,
          properties: properties,
        );
  }

  /// Track when user swipes in card-based bot interfaces
  static void trackBotSwiped({
    required String botName,
    required String direction,
    String? contentId,
  }) {
    Map<String, dynamic> properties = {
      'bot_name': botName,
      'direction': direction,
    };
    if (contentId != null) {
      properties['content_id'] = contentId;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.botSwiped,
          properties: properties,
        );
  }

  /// Track when user clicks on a bot in the explore page
  static void trackBotClicked({
    required String botName,
    required String botType,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.botClicked,
      properties: {
        'bot_name': botName,
        'bot_type': botType,
      },
    );
  }

  /// Track when user spends a credit
  static void trackCreditSpent({
    required String feature,
    required int remainingCredits,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.creditSpent,
      properties: {
        'feature': feature,
        'remaining_credits': remainingCredits,
      },
    );
  }

  /// Track when user reaches credit limit
  static void trackCreditLimitReached({
    required String feature,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.creditLimitReached,
      properties: {
        'feature': feature,
      },
    );
  }

  /// Track when daily credits are refreshed
  static void trackDailyCreditRefreshed({
    required int newCreditAmount,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.dailyCreditRefreshed,
      properties: {
        'new_credit_amount': newCreditAmount,
      },
    );
  }

  /// Track when user is prompted to upgrade
  static void trackUserPromptedForUpgrade({
    required String source,
    required String reason,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.userPromptedForUpgrade,
      properties: {
        'source': source,
        'reason': reason,
      },
    );
  }

  /// Track when user selects a recommended topic
  static void trackRecommendedTopicSelected({
    required String topic,
    String? category,
  }) {
    Map<String, dynamic> properties = {
      'topic': topic,
    };
    if (category != null) {
      properties['category'] = category;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.recommendedTopicSelected,
          properties: properties,
        );
  }

  /// Track when user sends a chat message
  static void trackChatMessageSent({
    required String botName,
    required int messageLength,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.chatMessageSent,
      properties: {
        'bot_name': botName,
        'message_length': messageLength,
      },
    );
  }

  /// Track specific bot usage events
  static void trackBotUsed({required String botName, required String query}) {
    String eventName;

    // Determine which event to use based on bot name
    switch (botName.toLowerCase()) {
      case 'discuss':
      case 'clearit':
        eventName = AnalyticsEvents.discussBotUsed;
        break;
      case 'compare':
      case 'comparego':
        eventName = AnalyticsEvents.compareGoBotUsed;
        break;
      case 'timeline':
      case 'timeliner':
        eventName = AnalyticsEvents.timelineBotUsed;
        break;
      case '5 pointer':
      case 'five pointer':
        eventName = AnalyticsEvents.fivePointerBotUsed;
        break;
      case 'yesno':
        eventName = AnalyticsEvents.yesNoBotUsed;
        break;
      case 'swiper':
        eventName = AnalyticsEvents.swiperBotUsed;
        break;
      default:
        eventName = AnalyticsEvents.defaultBotUsed;
    }

    ServiceLocator().analyticsService.trackEvent(
      eventName,
      properties: {'query': query},
    );
  }

  /// Track when content is added to library
  static void trackContentAddedToLibrary({
    required String contentType,
    required String query,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.contentAddedToLibrary,
      properties: {
        'content_type': contentType,
        'query': query,
      },
    );
  }

  /// Track when library limit is reached
  static void trackLibraryLimitReached() {
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.libraryLimitReached,
        );
  }

  /// Track when content is viewed from library
  static void trackContentViewedFromLibrary({
    required String contentType,
    required String query,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.contentViewedFromLibrary,
      properties: {
        'content_type': contentType,
        'query': query,
      },
    );
  }

  /// Track when feedback is submitted
  static void trackFeedbackSubmitted({
    required int rating,
    String? feedback,
  }) {
    Map<String, dynamic> properties = {
      'rating': rating,
    };
    if (feedback != null && feedback.isNotEmpty) {
      properties['feedback'] = feedback;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.feedbackSubmitted,
          properties: properties,
        );
  }

  /// Track when app is rated
  static void trackAppRated({required int rating}) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.appRated,
      properties: {'rating': rating},
    );
  }

  /// Track when app is shared
  static void trackAppShared({required String platform}) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.appShared,
      properties: {'platform': platform},
    );
  }

  /// Track when user switches tabs in the app
  static void trackTabSwitched({
    required int previousTabIndex,
    required int currentTabIndex,
    required String previousTabName,
    required String currentTabName,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.tabSwitched,
      properties: {
        'previous_tab_index': previousTabIndex,
        'current_tab_index': currentTabIndex,
        'previous_tab_name': previousTabName,
        'current_tab_name': currentTabName,
      },
    );
  }

  /// Track when user changes theme
  static void trackThemeChanged({required String newTheme}) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.themeChanged,
      properties: {'new_theme': newTheme},
    );
  }

  /// Track when user clicks the upgrade button on settings page
  static void trackUpgradeButtonClickedFromSettings() {
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.upgradeButtonClickedFromSettings,
        );
  }

  /// Track when user clicks manage subscription
  static void trackManageSubscription() {
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.manageSubscription,
        );
  }

  /// Track when user clicks delete account
  static void trackDeleteAccount() {
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.deleteAccount,
        );
  }

  /// Track when user clicks help & support
  static void trackHelpAndSupportClicked() {
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.helpAndSupportClicked,
        );
  }

  /// Track when user clicks about section
  static void trackAboutClicked() {
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.aboutClicked,
        );
  }

  /// Track time spent on onboarding page
  static void trackOnboardingPageTimeSpent({
    required int pageIndex,
    required String pageTitle,
    required double timeSpentSeconds,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.onboardingPageTimeSpent,
      properties: {
        'page_index': pageIndex,
        'page_title': pageTitle,
        'time_spent_seconds': timeSpentSeconds,
      },
    );
  }

  /// Track when onboarding is completed
  static void trackOnboardingCompleted({
    required int totalPages,
    required double totalTimeSpent,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.onboardingCompleted,
      properties: {
        'total_pages': totalPages,
        'total_time_spent': totalTimeSpent,
      },
    );
  }

  /// Track when onboarding is skipped
  static void trackOnboardingSkipped({
    required int pageIndex,
    required String pageTitle,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.onboardingSkipped,
      properties: {
        'skipped_at_page': pageIndex,
        'page_title': pageTitle,
      },
    );
  }

  /// Track when study session starts
  static void trackStudySessionStarted({
    required String sessionType,
    required String topic,
    String? difficulty,
  }) {
    Map<String, dynamic> properties = {
      'session_type': sessionType,
      'topic': topic,
    };
    if (difficulty != null) {
      properties['difficulty'] = difficulty;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.studySessionStarted,
          properties: properties,
        );
  }

  /// Track when study session is completed
  static void trackStudySessionCompleted({
    required String sessionType,
    required String topic,
    required double durationMinutes,
    required int itemsCompleted,
    required double accuracyPercentage,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.studySessionCompleted,
      properties: {
        'session_type': sessionType,
        'topic': topic,
        'duration_minutes': durationMinutes,
        'items_completed': itemsCompleted,
        'accuracy_percentage': accuracyPercentage,
      },
    );
  }

  /// Track when study session is paused
  static void trackStudySessionPaused({
    required String sessionType,
    required double durationSoFar,
    required int itemsCompletedSoFar,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.studySessionPaused,
      properties: {
        'session_type': sessionType,
        'duration_so_far': durationSoFar,
        'items_completed_so_far': itemsCompletedSoFar,
      },
    );
  }

  /// Track when study session is resumed
  static void trackStudySessionResumed({
    required String sessionType,
    required double pausedDuration,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.studySessionResumed,
      properties: {
        'session_type': sessionType,
        'paused_duration': pausedDuration,
      },
    );
  }

  /// Track when study session is abandoned
  static void trackStudySessionAbandoned({
    required String sessionType,
    required String topic,
    required double durationMinutes,
    required int itemsCompleted,
    required String reason,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.studySessionAbandoned,
      properties: {
        'session_type': sessionType,
        'topic': topic,
        'duration_minutes': durationMinutes,
        'items_completed': itemsCompleted,
        'reason': reason,
      },
    );
  }

  /// Track when study session is restarted
  static void trackStudySessionRestarted({
    required String sessionType,
    required String topic,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.studySessionRestarted,
      properties: {
        'session_type': sessionType,
        'topic': topic,
      },
    );
  }

  /// Track when study session format is selected
  static void trackStudySessionFormatSelected({
    required String format,
    required String topic,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.studySessionFormatSelected,
      properties: {
        'format': format,
        'topic': topic,
      },
    );
  }

  /// Track when streak is started
  static void trackStreakStarted() {
    ServiceLocator().analyticsService.trackEvent(AnalyticsEvents.streakStarted);
  }

  /// Track when streak is extended
  static void trackStreakExtended({
    required int newStreakCount,
    required int consecutiveDays,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.streakExtended,
      properties: {
        'new_streak_count': newStreakCount,
        'consecutive_days': consecutiveDays,
      },
    );
  }

  /// Track when streak is broken
  static void trackStreakBroken({
    required int previousStreakCount,
    required int daysSinceLastStudy,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.streakBroken,
      properties: {
        'previous_streak_count': previousStreakCount,
        'days_since_last_study': daysSinceLastStudy,
      },
    );
  }

  /// Track when streak milestone is reached
  static void trackStreakMilestoneReached({
    required int streakCount,
    required String milestone,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.streakMilestoneReached,
      properties: {
        'streak_count': streakCount,
        'milestone': milestone,
      },
    );
  }

  /// Track when streak page is viewed
  static void trackStreakPageViewed({
    required int currentStreak,
    required int bestStreak,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.streakPageViewed,
      properties: {
        'current_streak': currentStreak,
        'best_streak': bestStreak,
      },
    );
  }

  /// Track when flashcard type is selected
  static void trackFlashcardTypeSelected({
    required String flashcardType,
    required String topic,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardTypeSelected,
      properties: {
        'flashcard_type': flashcardType,
        'topic': topic,
      },
    );
  }

  /// Track when flashcard is created
  static void trackFlashcardCreated({
    required String flashcardType,
    required String topic,
    required int numberOfCards,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardCreated,
      properties: {
        'flashcard_type': flashcardType,
        'topic': topic,
        'number_of_cards': numberOfCards,
      },
    );
  }

  /// Track when flashcard is answered
  static void trackFlashcardAnswered({
    required String flashcardType,
    required bool isCorrect,
    required double responseTime,
    String? difficulty,
  }) {
    Map<String, dynamic> properties = {
      'flashcard_type': flashcardType,
      'is_correct': isCorrect,
      'response_time': responseTime,
    };
    if (difficulty != null) {
      properties['difficulty'] = difficulty;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.flashcardAnswered,
          properties: properties,
        );
  }

  /// Track when flashcard set is completed
  static void trackFlashcardSetCompleted({
    required String flashcardType,
    required String topic,
    required int totalCards,
    required int correctAnswers,
    required double durationMinutes,
    required double averageResponseTime,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardSetCompleted,
      properties: {
        'flashcard_type': flashcardType,
        'topic': topic,
        'total_cards': totalCards,
        'correct_answers': correctAnswers,
        'accuracy_percentage': (correctAnswers / totalCards) * 100,
        'duration_minutes': durationMinutes,
        'average_response_time': averageResponseTime,
      },
    );
  }

  /// Track when flashcard difficulty is changed
  static void trackFlashcardDifficultyChanged({
    required String flashcardType,
    required String oldDifficulty,
    required String newDifficulty,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardDifficultyChanged,
      properties: {
        'flashcard_type': flashcardType,
        'old_difficulty': oldDifficulty,
        'new_difficulty': newDifficulty,
      },
    );
  }

  /// Track when flashcard is restarted
  static void trackFlashcardRestarted({
    required String flashcardType,
    required String topic,
    required int previousProgress,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardRestarted,
      properties: {
        'flashcard_type': flashcardType,
        'topic': topic,
        'previous_progress': previousProgress,
      },
    );
  }

  /// Track when flashcard is skipped
  static void trackFlashcardSkipped({
    required String flashcardType,
    required String reason,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardSkipped,
      properties: {
        'flashcard_type': flashcardType,
        'reason': reason,
      },
    );
  }

  /// Track when flashcard is marked for review
  static void trackFlashcardMarkedForReview({
    required String flashcardType,
    required String topic,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardMarkedForReview,
      properties: {
        'flashcard_type': flashcardType,
        'topic': topic,
      },
    );
  }

  /// Track when user enters a query/topic for flashcard generation
  static void trackFlashcardQueryEntered({
    required String query,
    required String flashcardType,
    String? source, // 'manual_input', 'recommended_topic', 'search_suggestion'
  }) {
    Map<String, dynamic> properties = {
      'query': query,
      'flashcard_type': flashcardType,
      'query_length': query.length,
    };
    if (source != null) {
      properties['source'] = source;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.flashcardQueryEntered,
          properties: properties,
        );
  }

  /// Track when flashcard generation starts
  static void trackFlashcardGenerationStarted({
    required String topic,
    required String flashcardType,
    bool isStreaming = false,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardGenerationStarted,
      properties: {
        'topic': topic,
        'flashcard_type': flashcardType,
        'is_streaming': isStreaming,
      },
    );
  }

  /// Track when flashcard generation completes successfully
  static void trackFlashcardGenerationCompleted({
    required String topic,
    required String flashcardType,
    required int durationMs,
    bool isStreaming = false,
    int? numQuestions,
  }) {
    Map<String, dynamic> properties = {
      'topic': topic,
      'flashcard_type': flashcardType,
      'duration_ms': durationMs,
      'is_streaming': isStreaming,
    };
    if (numQuestions != null) {
      properties['num_questions'] = numQuestions;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.flashcardGenerationCompleted,
          properties: properties,
        );
  }

  /// Track when flashcard generation fails
  static void trackFlashcardGenerationFailed({
    required String topic,
    required String flashcardType,
    required String errorType,
    String? errorMessage,
    bool isStreaming = false,
  }) {
    Map<String, dynamic> properties = {
      'topic': topic,
      'flashcard_type': flashcardType,
      'error_type': errorType,
      'is_streaming': isStreaming,
    };
    if (errorMessage != null) {
      properties['error_message'] = errorMessage;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.flashcardGenerationFailed,
          properties: properties,
        );
  }

  /// Track when flashcard streaming starts
  static void trackFlashcardStreamingStarted({
    required String topic,
    required String flashcardType,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardStreamingStarted,
      properties: {
        'topic': topic,
        'flashcard_type': flashcardType,
      },
    );
  }

  /// Track when flashcard streaming completes
  static void trackFlashcardStreamingCompleted({
    required String topic,
    required String flashcardType,
    required int durationMs,
    required bool wasCompleteFlashcard,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.flashcardStreamingCompleted,
      properties: {
        'topic': topic,
        'flashcard_type': flashcardType,
        'duration_ms': durationMs,
        'was_complete_flashcard': wasCompleteFlashcard,
      },
    );
  }

  /// Track when flashcard streaming is cancelled
  static void trackFlashcardStreamingCancelled({
    required String topic,
    required String flashcardType,
    required int durationMs,
    String? reason,
  }) {
    Map<String, dynamic> properties = {
      'topic': topic,
      'flashcard_type': flashcardType,
      'duration_ms': durationMs,
    };
    if (reason != null) {
      properties['reason'] = reason;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.flashcardStreamingCancelled,
          properties: properties,
        );
  }

  /// Track when a deck is created
  static void trackDeckCreated({
    required String deckName,
    required String deckEmoji,
    String? description,
  }) {
    Map<String, dynamic> properties = {
      'deck_name': deckName,
      'deck_emoji': deckEmoji,
    };
    if (description != null && description.isNotEmpty) {
      properties['has_description'] = true;
      properties['description_length'] = description.length;
    } else {
      properties['has_description'] = false;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.deckCreated,
          properties: properties,
        );
  }

  /// Track when a deck is deleted
  static void trackDeckDeleted({
    required String deckId,
    required String deckName,
    required int nodeCount,
    required int completedNodes,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.deckDeleted,
      properties: {
        'deck_id': deckId,
        'deck_name': deckName,
        'node_count': nodeCount,
        'completed_nodes': completedNodes,
        'completion_percentage':
            nodeCount > 0 ? (completedNodes / nodeCount) * 100 : 0,
      },
    );
  }

  /// Track when a deck is viewed
  static void trackDeckViewed({
    required String deckId,
    required String deckName,
    required int nodeCount,
    required int completedNodes,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.deckViewed,
      properties: {
        'deck_id': deckId,
        'deck_name': deckName,
        'node_count': nodeCount,
        'completed_nodes': completedNodes,
        'completion_percentage':
            nodeCount > 0 ? (completedNodes / nodeCount) * 100 : 0,
      },
    );
  }

  /// Track when study session starts for a deck
  static void trackDeckStudyStarted({
    required String deckId,
    required String deckName,
    required String nodeId,
    required String nodeTopic,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.deckStudyStarted,
      properties: {
        'deck_id': deckId,
        'deck_name': deckName,
        'node_id': nodeId,
        'node_topic': nodeTopic,
      },
    );
  }

  /// Track when deck study session is completed
  static void trackDeckStudyCompleted({
    required String deckId,
    required String deckName,
    required String nodeId,
    required String nodeTopic,
    required int durationMinutes,
    required double completionScore,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.deckStudyCompleted,
      properties: {
        'deck_id': deckId,
        'deck_name': deckName,
        'node_id': nodeId,
        'node_topic': nodeTopic,
        'duration_minutes': durationMinutes,
        'completion_score': completionScore,
      },
    );
  }

  /// Track when a deck node is completed
  static void trackDeckNodeCompleted({
    required String deckId,
    required String deckName,
    required String nodeId,
    required String nodeTopic,
    required double score,
    required int durationMinutes,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.deckNodeCompleted,
      properties: {
        'deck_id': deckId,
        'deck_name': deckName,
        'node_id': nodeId,
        'node_topic': nodeTopic,
        'score': score,
        'duration_minutes': durationMinutes,
      },
    );
  }

  /// Track when deck progress is viewed
  static void trackDeckProgressViewed({
    required String deckId,
    required String deckName,
    required int totalNodes,
    required int completedNodes,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.deckProgressViewed,
      properties: {
        'deck_id': deckId,
        'deck_name': deckName,
        'total_nodes': totalNodes,
        'completed_nodes': completedNodes,
        'completion_percentage':
            totalNodes > 0 ? (completedNodes / totalNodes) * 100 : 0,
      },
    );
  }

  /// Track when a deck is shared
  static void trackDeckShared({
    required String deckId,
    required String deckName,
    required String shareMethod, // 'link', 'export', 'social'
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.deckShared,
      properties: {
        'deck_id': deckId,
        'deck_name': deckName,
        'share_method': shareMethod,
      },
    );
  }

  /// Track when a deck is renamed
  static void trackDeckRenamed({
    required String deckId,
    required String oldName,
    required String newName,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.deckRenamed,
      properties: {
        'deck_id': deckId,
        'old_name': oldName,
        'new_name': newName,
      },
    );
  }

  /// Track when progress is viewed
  static void trackProgressViewed({
    required String viewType, // 'daily', 'weekly', 'monthly', 'dashboard'
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.progressViewed,
      properties: {
        'view_type': viewType,
      },
    );
  }

  /// Track when daily goal is set
  static void trackDailyGoalSet({
    required int studyTimeMinutes,
    required int cardsPerDay,
    required int accuracyGoal,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.dailyGoalSet,
      properties: {
        'study_time_minutes': studyTimeMinutes,
        'cards_per_day': cardsPerDay,
        'accuracy_goal': accuracyGoal,
      },
    );
  }

  /// Track when daily goal is achieved
  static void trackDailyGoalAchieved({
    required String goalType, // 'study_time', 'cards', 'accuracy'
    required double actualValue,
    required double targetValue,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.dailyGoalAchieved,
      properties: {
        'goal_type': goalType,
        'actual_value': actualValue,
        'target_value': targetValue,
        'achievement_percentage': (actualValue / targetValue) * 100,
      },
    );
  }

  /// Track when daily goal is missed
  static void trackDailyGoalMissed({
    required String goalType,
    required double actualValue,
    required double targetValue,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.dailyGoalMissed,
      properties: {
        'goal_type': goalType,
        'actual_value': actualValue,
        'target_value': targetValue,
        'completion_percentage': (actualValue / targetValue) * 100,
      },
    );
  }

  /// Track when weekly progress is viewed
  static void trackWeeklyProgressViewed({
    required int weekNumber,
    required int studyDays,
    required double totalStudyHours,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.weeklyProgressViewed,
      properties: {
        'week_number': weekNumber,
        'study_days': studyDays,
        'total_study_hours': totalStudyHours,
      },
    );
  }

  /// Track when monthly progress is viewed
  static void trackMonthlyProgressViewed({
    required int month,
    required int year,
    required int studyDays,
    required double totalStudyHours,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.monthlyProgressViewed,
      properties: {
        'month': month,
        'year': year,
        'study_days': studyDays,
        'total_study_hours': totalStudyHours,
      },
    );
  }

  /// Track when roadmap is created
  static void trackRoadmapCreated({
    required String roadmapTitle,
    required String subject,
    required int numberOfNodes,
    String? difficulty,
  }) {
    Map<String, dynamic> properties = {
      'roadmap_title': roadmapTitle,
      'subject': subject,
      'number_of_nodes': numberOfNodes,
    };
    if (difficulty != null) {
      properties['difficulty'] = difficulty;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.roadmapCreated,
          properties: properties,
        );
  }

  /// Track when roadmap is viewed
  static void trackRoadmapViewed({
    required String roadmapTitle,
    required String subject,
    required int completedNodes,
    required int totalNodes,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.roadmapViewed,
      properties: {
        'roadmap_title': roadmapTitle,
        'subject': subject,
        'completed_nodes': completedNodes,
        'total_nodes': totalNodes,
        'completion_percentage': (completedNodes / totalNodes) * 100,
      },
    );
  }

  /// Track when roadmap node is completed
  static void trackRoadmapNodeCompleted({
    required String roadmapTitle,
    required String nodeTitle,
    required int nodeIndex,
    required int totalNodes,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.roadmapNodeCompleted,
      properties: {
        'roadmap_title': roadmapTitle,
        'node_title': nodeTitle,
        'node_index': nodeIndex,
        'total_nodes': totalNodes,
        'completion_percentage': ((nodeIndex + 1) / totalNodes) * 100,
      },
    );
  }

  /// Track when roadmap is deleted
  static void trackRoadmapDeleted({
    required String roadmapTitle,
    required String subject,
    required int completedNodes,
    required int totalNodes,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.roadmapDeleted,
      properties: {
        'roadmap_title': roadmapTitle,
        'subject': subject,
        'completed_nodes': completedNodes,
        'total_nodes': totalNodes,
      },
    );
  }

  /// Track when roadmap is shared
  static void trackRoadmapShared({
    required String roadmapTitle,
    required String shareMethod,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.roadmapShared,
      properties: {
        'roadmap_title': roadmapTitle,
        'share_method': shareMethod,
      },
    );
  }

  /// Track when library is filtered
  static void trackLibraryFiltered({
    required String filterType,
    required String filterValue,
    required int resultCount,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.libraryFiltered,
      properties: {
        'filter_type': filterType,
        'filter_value': filterValue,
        'result_count': resultCount,
      },
    );
  }

  /// Track when library is searched
  static void trackLibrarySearched({
    required String searchQuery,
    required int resultCount,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.librarySearched,
      properties: {
        'search_query': searchQuery,
        'result_count': resultCount,
      },
    );
  }

  /// Track when content is deleted
  static void trackContentDeleted({
    required String contentType,
    required String contentTitle,
    String? reason,
  }) {
    Map<String, dynamic> properties = {
      'content_type': contentType,
      'content_title': contentTitle,
    };
    if (reason != null) {
      properties['reason'] = reason;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.contentDeleted,
          properties: properties,
        );
  }

  /// Track when content is exported
  static void trackContentExported({
    required String contentType,
    required String exportFormat,
    required int itemCount,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.contentExported,
      properties: {
        'content_type': contentType,
        'export_format': exportFormat,
        'item_count': itemCount,
      },
    );
  }

  /// Track when content is renamed
  static void trackContentRenamed({
    required String contentType,
    required String oldName,
    required String newName,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.contentRenamed,
      properties: {
        'content_type': contentType,
        'old_name': oldName,
        'new_name': newName,
      },
    );
  }

  /// Track when app is opened
  static void trackAppOpened({
    required String source, // 'icon', 'notification', 'deeplink'
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.appOpened,
      properties: {
        'source': source,
      },
    );
  }

  /// Track when app is backgrounded
  static void trackAppBackgrounded({
    required double sessionDuration,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.appBackgrounded,
      properties: {
        'session_duration': sessionDuration,
      },
    );
  }

  /// Track when app is resumed
  static void trackAppResumed({
    required double backgroundDuration,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.appResumed,
      properties: {
        'background_duration': backgroundDuration,
      },
    );
  }

  /// Track when user session starts
  static void trackSessionStarted() {
    ServiceLocator()
        .analyticsService
        .trackEvent(AnalyticsEvents.sessionStarted);
  }

  /// Track when user session ends
  static void trackSessionEnded({
    required double sessionDuration,
    required int actionsPerformed,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.sessionEnded,
      properties: {
        'session_duration': sessionDuration,
        'actions_performed': actionsPerformed,
      },
    );
  }

  /// Track when reminder is set
  static void trackReminderSet({
    required String reminderType,
    required String frequency,
    required String time,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.reminderSet,
      properties: {
        'reminder_type': reminderType,
        'frequency': frequency,
        'time': time,
      },
    );
  }

  /// Track when reminder is triggered
  static void trackReminderTriggered({
    required String reminderType,
    required bool userResponded,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.reminderTriggered,
      properties: {
        'reminder_type': reminderType,
        'user_responded': userResponded,
      },
    );
  }

  /// Track when tutorial is viewed
  static void trackTutorialViewed({
    required String tutorialName,
    required String section,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.tutorialViewed,
      properties: {
        'tutorial_name': tutorialName,
        'section': section,
      },
    );
  }

  /// Track when help documentation is viewed
  static void trackHelpDocumentationViewed({
    required String documentTitle,
    required String category,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.helpDocumentationViewed,
      properties: {
        'document_title': documentTitle,
        'category': category,
      },
    );
  }

  /// Track when feature tour is started
  static void trackFeatureTourStarted({
    required String featureName,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.featureTourStarted,
      properties: {
        'feature_name': featureName,
      },
    );
  }

  /// Track when feature tour is completed
  static void trackFeatureTourCompleted({
    required String featureName,
    required int stepsCompleted,
    required int totalSteps,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.featureTourCompleted,
      properties: {
        'feature_name': featureName,
        'steps_completed': stepsCompleted,
        'total_steps': totalSteps,
      },
    );
  }

  /// Track load time performance
  static void trackLoadTimeTracked({
    required String screen,
    required double loadTimeMs,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.loadTimeTracked,
      properties: {
        'screen': screen,
        'load_time_ms': loadTimeMs,
      },
    );
  }

  /// Track memory usage
  static void trackMemoryUsageTracked({
    required double memoryUsageMB,
    required String context,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.memoryUsageTracked,
      properties: {
        'memory_usage_mb': memoryUsageMB,
        'context': context,
      },
    );
  }

  /// Track app crash
  static void trackAppCrash({
    required String crashType,
    required String errorMessage,
    String? stackTrace,
  }) {
    Map<String, dynamic> properties = {
      'crash_type': crashType,
      'error_message': errorMessage,
    };
    if (stackTrace != null) {
      properties['stack_trace'] = stackTrace;
    }
    ServiceLocator().analyticsService.trackEvent(
          AnalyticsEvents.appCrash,
          properties: properties,
        );
  }

  /// Track when achievement is unlocked
  static void trackAchievementUnlocked({
    required String achievementName,
    required String category,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.achievementUnlocked,
      properties: {
        'achievement_name': achievementName,
        'category': category,
      },
    );
  }

  /// Track when achievement is shared
  static void trackAchievementShared({
    required String achievementName,
    required String shareMethod,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.achievementShared,
      properties: {
        'achievement_name': achievementName,
        'share_method': shareMethod,
      },
    );
  }

  /// Track when invite friend is sent
  static void trackInviteFriendSent({
    required String inviteMethod,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.inviteFriendSent,
      properties: {
        'invite_method': inviteMethod,
      },
    );
  }

  /// Track when badge is earned
  static void trackBadgeEarned({
    required String badgeName,
    required String category,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.badgeEarned,
      properties: {
        'badge_name': badgeName,
        'category': category,
      },
    );
  }

  /// Track when user levels up
  static void trackLevelUp({
    required int newLevel,
    required int pointsEarned,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.levelUp,
      properties: {
        'new_level': newLevel,
        'points_earned': pointsEarned,
      },
    );
  }

  /// Track when points are earned
  static void trackPointsEarned({
    required int pointsEarned,
    required String source,
    required int totalPoints,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.pointsEarned,
      properties: {
        'points_earned': pointsEarned,
        'source': source,
        'total_points': totalPoints,
      },
    );
  }

  /// Track when notification settings are changed
  static void trackNotificationSettingsChanged({
    required String settingType,
    required bool newValue,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.notificationSettingsChanged,
      properties: {
        'setting_type': settingType,
        'new_value': newValue,
      },
    );
  }

  /// Track when privacy settings are changed
  static void trackPrivacySettingsChanged({
    required String settingType,
    required bool newValue,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.privacySettingsChanged,
      properties: {
        'setting_type': settingType,
        'new_value': newValue,
      },
    );
  }

  /// Track when language is changed
  static void trackLanguageChanged({
    required String oldLanguage,
    required String newLanguage,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.languageChanged,
      properties: {
        'old_language': oldLanguage,
        'new_language': newLanguage,
      },
    );
  }

  /// Track when font size is changed
  static void trackFontSizeChanged({
    required String oldSize,
    required String newSize,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.fontSizeChanged,
      properties: {
        'old_size': oldSize,
        'new_size': newSize,
      },
    );
  }

  /// Track global search
  static void trackGlobalSearch({
    required String searchQuery,
    required int resultCount,
    required String searchScope,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.globalSearch,
      properties: {
        'search_query': searchQuery,
        'result_count': resultCount,
        'search_scope': searchScope,
      },
    );
  }

  /// Track when search result is clicked
  static void trackSearchResultClicked({
    required String searchQuery,
    required String resultTitle,
    required int resultPosition,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.searchResultClicked,
      properties: {
        'search_query': searchQuery,
        'result_title': resultTitle,
        'result_position': resultPosition,
      },
    );
  }

  /// Track when filter is applied
  static void trackFilterApplied({
    required String filterType,
    required String filterValue,
    required String context,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.filterApplied,
      properties: {
        'filter_type': filterType,
        'filter_value': filterValue,
        'context': context,
      },
    );
  }

  /// Track when sort order is changed
  static void trackSortOrderChanged({
    required String sortBy,
    required String sortOrder, // 'asc' or 'desc'
    required String context,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.sortOrderChanged,
      properties: {
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'context': context,
      },
    );
  }

  /// Track when card is swiped left
  static void trackCardSwipedLeft({
    required String cardType,
    required String content,
    required int cardIndex,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.cardSwipedLeft,
      properties: {
        'card_type': cardType,
        'content': content,
        'card_index': cardIndex,
      },
    );
  }

  /// Track when card is swiped right
  static void trackCardSwipedRight({
    required String cardType,
    required String content,
    required int cardIndex,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.cardSwipedRight,
      properties: {
        'card_type': cardType,
        'content': content,
        'card_index': cardIndex,
      },
    );
  }

  /// Track when quiz answer is correct
  static void trackQuizAnswerCorrect({
    required String quizType,
    required String question,
    required double responseTime,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.quizAnswerCorrect,
      properties: {
        'quiz_type': quizType,
        'question': question,
        'response_time': responseTime,
      },
    );
  }

  /// Track when quiz answer is incorrect
  static void trackQuizAnswerIncorrect({
    required String quizType,
    required String question,
    required String userAnswer,
    required String correctAnswer,
    required double responseTime,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.quizAnswerIncorrect,
      properties: {
        'quiz_type': quizType,
        'question': question,
        'user_answer': userAnswer,
        'correct_answer': correctAnswer,
        'response_time': responseTime,
      },
    );
  }

  /// Track when quiz is completed
  static void trackQuizCompleted({
    required String quizType,
    required int totalQuestions,
    required int correctAnswers,
    required double durationSeconds,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.quizCompleted,
      properties: {
        'quiz_type': quizType,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'accuracy_percentage': (correctAnswers / totalQuestions) * 100,
        'duration_seconds': durationSeconds,
      },
    );
  }

  /// Track when quiz is restarted
  static void trackQuizRestarted({
    required String quizType,
    required String topic,
    required int previousProgress,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.quizRestarted,
      properties: {
        'quiz_type': quizType,
        'topic': topic,
        'previous_progress': previousProgress,
      },
    );
  }

  /// Track when modal is opened
  static void trackModalOpened({
    required String modalType,
    required String context,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.modalOpened,
      properties: {
        'modal_type': modalType,
        'context': context,
      },
    );
  }

  /// Track when modal is closed
  static void trackModalClosed({
    required String modalType,
    required String closeMethod, // 'button', 'gesture', 'timeout'
    required double timeSpent,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.modalClosed,
      properties: {
        'modal_type': modalType,
        'close_method': closeMethod,
        'time_spent': timeSpent,
      },
    );
  }

  /// Track when dialog is confirmed
  static void trackDialogConfirmed({
    required String dialogType,
    required String context,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.dialogConfirmed,
      properties: {
        'dialog_type': dialogType,
        'context': context,
      },
    );
  }

  /// Track when dialog is cancelled
  static void trackDialogCancelled({
    required String dialogType,
    required String context,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.dialogCancelled,
      properties: {
        'dialog_type': dialogType,
        'context': context,
      },
    );
  }

  /// Track when paywall is viewed
  static void trackPaywallViewed({
    required String source,
    required String trigger,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.paywallViewed,
      properties: {
        'source': source,
        'trigger': trigger,
      },
    );
  }

  /// Track when paywall is dismissed
  static void trackPaywallDismissed({
    required String source,
    required String dismissMethod,
    required double timeSpent,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.paywallDismissed,
      properties: {
        'source': source,
        'dismiss_method': dismissMethod,
        'time_spent': timeSpent,
      },
    );
  }

  /// Track when subscription page is viewed
  static void trackSubscriptionPageViewed({
    required String source,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.subscriptionPageViewed,
      properties: {
        'source': source,
      },
    );
  }

  /// Track when free tier limit is hit
  static void trackFreeTierLimitHit({
    required String limitType,
    required int currentUsage,
    required int limit,
  }) {
    ServiceLocator().analyticsService.trackEvent(
      AnalyticsEvents.freeTierLimitHit,
      properties: {
        'limit_type': limitType,
        'current_usage': currentUsage,
        'limit': limit,
      },
    );
  }
}
