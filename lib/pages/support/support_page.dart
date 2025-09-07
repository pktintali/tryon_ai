import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tryon_ai/routes/routes_name.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.theme.primaryColor.withOpacity(0.1),
              context.theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: context.theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        'Help & Support',
                        style: TextStyle(
                          color: context.theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.theme.primaryColor.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Welcome Section
                        _buildWelcomeSection(),
                        const SizedBox(height: 32),

                        // Quick Actions
                        _buildQuickActionsSection(),
                        const SizedBox(height: 32),

                        // Contact Options
                        _buildContactSection(),
                        const SizedBox(height: 32),

                        // FAQ Section
                        _buildFAQSection(),
                        const SizedBox(height: 32),

                        // App Info
                        _buildAppInfoSection(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.theme.primaryColor,
            context.theme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.support_agent,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We\'re Here to Help!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get assistance, share feedback, or explore our resources. We\'re committed to making your TryOn AI experience amazing.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Share your thoughts',
                color: Colors.blue,
                onTap: () => context.goNamed(RoutesName.feedback),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.bug_report_outlined,
                title: 'Report Bug',
                subtitle: 'Found an issue?',
                color: Colors.red,
                onTap: () => _reportBug(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color:
                    context.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get in Touch',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactCard(
          icon: Icons.chat_bubble_outline,
          title: 'WhatsApp Support',
          subtitle: 'Chat with our support team',
          detail: '+91 7985270343',
          color: Colors.green,
          onTap: () => _openWhatsApp(),
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.email_outlined,
          title: 'Email Support',
          subtitle: 'Send us a detailed message',
          detail: 'tdeveloperindia@gmail.com',
          color: Colors.blue,
          onTap: () => _sendEmail(),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String detail,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.theme.dividerColor.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color:
                  context.theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'How do I try on clothes with TryOn AI?',
        'answer':
            'First, set up your avatar by taking a photo or selecting from the gallery. Then, share product images or URLs from shopping apps/websites. Our AI will generate a realistic try-on result showing how the outfit looks on you.'
      },
      {
        'question': 'Is my avatar and data safe?',
        'answer':
            'Absolutely! All your photos and data are stored securely on your device and our secure servers. We never share your personal information or avatar photos with third parties.'
      },
      {
        'question': 'Supported e-commerce platforms?',
        'answer':
            'Currently, Amazon and Myntra support direct sharing, but in the future we will be adding support to other platforms as well. For now, for other platforms you can take a screenshot of the product and share it with TryOn AI.'
      },
      {
        'question': 'What types of products can I try on?',
        'answer':
            'Currently, TryOn AI supports various clothing items like shirts, t-shirts, dresses, jackets, and more. We also support other wearables including hats, caps, jewelry, accessories, sunglasses, and watches.'
      },
      {
        'question': 'How do I save and view my try-on results?',
        'answer':
            'After generating a try-on result, tap the "Save" button to save it to both your device gallery and the "My Try-Ons" page within the app. You can view, share, or delete saved try-ons anytime from the My Try-Ons section.'
      },
      {
        'question': 'Can I share try-on results with friends?',
        'answer':
            'Yes! You can share try-on results directly from the result page or from the My Try-Ons gallery. The share function works with any app that supports image sharing like WhatsApp, Instagram, or email.'
      },
      {
        'question': 'How accurate are the try-on results?',
        'answer':
            'Our AI technology provides realistic try-on previews, but results may vary based on image quality, lighting, and clothing type. For best results, use clear photos with good lighting when setting up your avatar.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...faqs.map((faq) => _buildFAQItem(
              question: faq['question']!,
              answer: faq['answer']!,
            )),
      ],
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.theme.textTheme.bodyLarge?.color,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color:
                    context.theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Center(
      child: Text(
        'Made with ❤️ by TDevelopers',
        style: TextStyle(
          fontSize: 16,
          color: context.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final whatsappUrl = Uri.parse(
        "https://wa.me/7985270343?text=Hello! I need help with TryOn AI.");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch WhatsApp');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening WhatsApp');
    }
  }

  Future<void> _sendEmail() async {
    final emailUrl = Uri(
      scheme: 'mailto',
      path: 'tdeveloperindia@gmail.com',
      query:
          'subject=TryOn AI Support Request&body=Hello,%0A%0APlease describe your issue or question:%0A%0A',
    );
    try {
      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
      } else {
        // Copy email to clipboard as fallback
        await Clipboard.setData(
            const ClipboardData(text: 'tdeveloperindia@gmail.com'));
        _showSuccessSnackBar('Email address copied to clipboard');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening email client');
    }
  }

  Future<void> _reportBug(BuildContext context) async {
    final emailUrl = Uri(
      scheme: 'mailto',
      path: 'tdeveloperindia@gmail.com',
      query:
          'subject=TryOn AI Bug Report&body=Hello,%0A%0ABug Description:%0A%0ASteps to Reproduce:%0A1.%0A2.%0A3.%0A%0AExpected Behavior:%0A%0AActual Behavior:%0A%0ADevice Info:%0A- Device: %0A- OS Version: %0A- App Version: 1.0.0%0A%0AAdditional Notes:%0A',
    );
    try {
      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch email client');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening email client');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
