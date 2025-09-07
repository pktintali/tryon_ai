import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tryon_ai/controllers/auth_controller.dart';
import 'package:tryon_ai/controllers/feedback_controller.dart';
import 'package:tryon_ai/models/feedback_model.dart';
import 'package:tryon_ai/pages/support/widgets/emoji_painter.dart';
import 'package:tryon_ai/routes/routes_name.dart';
import 'package:tryon_ai/services/analytics_helper.dart';
import 'package:tryon_ai/utils/core_utils.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:tryon_ai/widgets/pm_filled_button.dart';
import 'package:provider/provider.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        notificationPredicate: (_) => false,
        title: const Text("Feedback"),
        centerTitle: true,
      ),
      body: Consumer<FeedbackController>(
        builder: (context, controller, child) {
          return controller.sendingFeedBackToServer
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : PageView(
                  padEnds: true,
                  scrollDirection: Axis.vertical,
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        spacing: 24,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              'https://d18891bkk3ccc2.cloudfront.net/wp-content/uploads/2021/09/08145124/SHO_BLOG_EEFGuideance_210908-01.jpg',
                            ),
                          ),
                          Text(
                            "Shared Your FeedBack",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                          // const SizedBox(height: 24),
                          const Text(
                            "How was your experience with TryOn AI?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            spacing: 16,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              mouthPainters.length,
                              (index) {
                                return GestureDetector(
                                  onTap: () {
                                    controller.rating = index;
                                    Future.delayed(
                                            const Duration(milliseconds: 300))
                                        .then(
                                      (_) {
                                        controller.pageController.animateToPage(
                                            1,
                                            duration:
                                                const Duration(seconds: 1),
                                            curve: Curves.easeInOut);
                                      },
                                    );
                                  },
                                  child: CustomPaint(
                                    foregroundPainter: EmojiPainters(
                                      mouthPainter: mouthPainters[index],
                                    ),
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index == controller.rating
                                            ? Colors.yellow
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.dynamicFeedbackText(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                controller.feedbackTextEditingController,
                            onTapOutside: (_) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Enter your valuable feedback....",
                              fillColor: context.isDarkModeR
                                  ? Colors.black54
                                  : Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('may we follow you up on Your feedback?'),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Text("Yes"),
                                  Radio<bool>(
                                    value: true,
                                    groupValue: controller.isFollowUp,
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.isFollowUp = value;
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("No"),
                                  Radio<bool>(
                                    value: false,
                                    groupValue: controller.isFollowUp,
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.isFollowUp = value;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          PMFilledButton(
                            text: 'Submit',
                            onPressed: () async {
                              final user =
                                  context.read<AuthController>().getCurrentUser;
                              if (user != null) {
                                final feedBackData = FeedbackModel(
                                  feedBackText: controller
                                      .feedbackTextEditingController.text,
                                  isFollowUp: controller.isFollowUp,
                                  rating: controller.rating + 1,
                                  username: user.displayName ?? 'No_Name',
                                );
                                final idToken = await context
                                    .read<AuthController>()
                                    .getCurrentUserToken();
                                final isSent =
                                    await controller.sendFeedBackToServer(
                                  feedBackData,
                                  idToken,
                                );
                                if (isSent) {
                                  // Track feedback submission
                                  AnalyticsHelper.trackFeedbackSubmitted(
                                    rating: feedBackData.rating,
                                    feedback:
                                        feedBackData.feedBackText.isNotEmpty
                                            ? feedBackData.feedBackText
                                            : null,
                                  );

                                  if (context.mounted) {
                                    CoreUtils.showSackBar(context,
                                        content: "Thanks For Your Feedback");
                                    context.goNamed(RoutesName.settings);
                                    controller.reset();
                                  }
                                } else {
                                  if (context.mounted) {
                                    CoreUtils.showSackBar(context,
                                        content:
                                            "Something went wrong, please try again later");
                                    context.goNamed(RoutesName.settings);
                                    controller.reset();
                                  }
                                }
                              }
                              return;
                            },
                          )
                        ],
                      ),
                    )
                  ],
                );
        },
      ),
    );
  }
}
