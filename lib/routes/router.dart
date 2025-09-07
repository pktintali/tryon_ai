part of 'router.imports.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Create an analytics observer for tracking screen views
final _analyticsObserver = AnalyticsNavigationObserver();

GoRouter appRoute = GoRouter(
  navigatorKey: _rootNavigatorKey,
  observers: [_analyticsObserver],
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SimpleOnboardingPage();
      },
      redirect: (context, state) {
        final initialLocation = _getInitialRoute(context);
        return initialLocation;
      },
    ),
    GoRoute(
      path: '/auth',
      name: RoutesName.auth,
      builder: (BuildContext context, GoRouterState state) {
        return const PMAuthPage();
      },
    ),
    GoRoute(
      path: '/avatar-config',
      name: RoutesName.avatarConfig,
      builder: (BuildContext context, GoRouterState state) {
        return const AvatarConfigPage();
      },
    ),
    GoRoute(
      path: '/shared-item-preview',
      name: RoutesName.sharedItemPreview,
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SharedItemPreviewPage(
          imageFile: extra?['imageFile'],
          textOrUrl: extra?['textOrUrl'],
          title: extra?['title'],
        );
      },
    ),
    GoRoute(
      path: '/tryon-result',
      name: RoutesName.tryonResult,
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        return TryOnResultPage(
          resultImage: extra?['resultImage'],
          productUrl: extra?['productUrl'],
          ecomPlatform: extra?['ecomPlatform'],
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return TabPage(navigationShell: navigationShell);
      },
      branches: [
        // main home page
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: RoutesName.home,
              path: '/home',
              builder: (context, state) {
                return const HomePage();
              },
              routes: [
                // setting page
                GoRoute(
                  name: RoutesName.settings,
                  path: '/setting',
                  builder: (context, state) {
                    return const SettingPage();
                  },
                  routes: [
                    GoRoute(
                      path: '/support',
                      name: RoutesName.support,
                      builder: (BuildContext context, GoRouterState state) {
                        return const SupportPage();
                      },
                      routes: [
                        GoRoute(
                          path: '/feedback',
                          name: RoutesName.feedback,
                          builder: (context, state) {
                            return ChangeNotifierProvider(
                              create: (context) => FeedbackController(),
                              child: const FeedbackPage(),
                            );
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        // main explore page
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my_tryons',
              builder: (context, state) {
                return const MyTryOnsPage();
              },
            )
          ],
        ),
        // main library page
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/me',
              builder: (context, state) {
                return const SettingPage(
                  fromTab: true,
                );
              },
            )
          ],
        ),
        // flashcards page
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/flashcards',
              name: RoutesName.flashcards,
              builder: (context, state) {
                return const Center(
                  child: Text("Flashcards Page"),
                );
              },
            )
          ],
        )
      ],
    ),
  ],
);

String _getInitialRoute(BuildContext context) {
  final onBoardingDone =
      Hive.userBox.get(isOnboardingSeenKey, defaultValue: false) ?? false;
  final isAuthenticate =
      Hive.userBox.get(isLoggedInKey, defaultValue: false) ?? false;

  if (onBoardingDone && isAuthenticate) {
    return '/home';
  } else if (onBoardingDone) {
    return '/auth';
  }

  return '/';
}
