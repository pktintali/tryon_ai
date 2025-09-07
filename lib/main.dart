import 'dart:io' show Platform;

import 'package:analytics_service/analytics_service_package.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tryon_ai/controllers/app_controller.dart';
import 'package:tryon_ai/controllers/auth_controller.dart';
import 'package:tryon_ai/controllers/avatar_controller.dart';
import 'package:tryon_ai/controllers/product_controller.dart';
import 'package:tryon_ai/controllers/saved_images_controller.dart';
import 'package:tryon_ai/firebase_options.dart';
import 'package:tryon_ai/services/service_locator.dart';
import 'package:tryon_ai/services/share_handler.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:tryon_ai/utils/extensions.dart';
import 'package:tryon_ai/utils/themes/pm_theme.dart';
import 'package:tryon_ai/routes/router.imports.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive setup
  await Hive.initFlutter();
  await Hive.openBox<int>(creditBoxName);
  await Hive.openBox<String>(deviceTokenBoxName);
  await Hive.openBox<int>(timeStampBoxName);
  await Hive.openBox<bool>(userBoxName);

  // secrete setup
  await dotenv.load(fileName: '.env');

  // Initialize all services using the ServiceLocator
  final serviceLocator = ServiceLocator();

  // Get API keys from environment variables
  final purchasesApiKey = Platform.isIOS
      ? dotenv.env['REVENUECAT_IOS_KEY'] ?? ''
      : dotenv.env['REVENUECAT_ANDROID_KEY'] ?? '';

  // Initialize Mixpanel analytics
  final mixpanelToken = dotenv.env['MIXPANEL_TOKEN'] ?? '';

  // Initialize all services
  await serviceLocator.initializeServices(
    purchasesApiKey: purchasesApiKey,
    mixpanelToken: mixpanelToken,
    purchasesObserverMode: false, // Set to true for testing
  );

  // Create auth controller using the service from the ServiceLocator
  final authController = AuthController(
    serviceLocator.authService,
    serviceLocator.purchasesService,
  );

  // Create Try-On AI controllers
  final avatarController = AvatarProvider();
  final productController = ProductController();
  final savedImagesController = SavedImagesController();

  // Load the Try-On AI data
  await Future.wait([
    avatarController.load(),
    productController.load(),
  ]);

  // make fixed device orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // finally running the app with the upgrade alert
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppController()),
        ChangeNotifierProvider(create: (context) => authController),
        ChangeNotifierProvider.value(value: avatarController),
        ChangeNotifierProvider.value(value: productController),
        ChangeNotifierProvider.value(value: savedImagesController),
        // You can also provide direct access to services as needed
        Provider.value(value: serviceLocator.purchasesService),
      ],
      child: const AnalyticsLifecycleObserver(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ShareHandler shareHandler;

  @override
  void initState() {
    super.initState();
    shareHandler = ShareHandler(appRoute.routerDelegate.navigatorKey);

    // Start listening after the first frame, but delay initial share handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shareHandler.startListening();
      // Don't handle initial share immediately - let the share handler handle timing
      Future.delayed(const Duration(milliseconds: 100), () {
        shareHandler.handleInitialShare();
      });
    });
  }

  @override
  void dispose() {
    shareHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRoute,
      title: 'TryOn AI',
      theme: PMTheme.light,
      darkTheme: PMTheme.dark,
      themeAnimationDuration: const Duration(milliseconds: 700),
      themeAnimationCurve: Curves.easeInOutCirc,
      themeMode: context.isDarkModeR ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        final upgrader = Upgrader(
          durationUntilAlertAgain: const Duration(days: 7),
          minAppVersion: '2.0.6+34',
        );
        return UpgradeAlert(
          navigatorKey: appRoute.routerDelegate.navigatorKey,
          upgrader: upgrader,
          showLater: true,
          child: child,
        );
      },
    );
  }
}
