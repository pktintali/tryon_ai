import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tryon_ai/services/analytics_helper.dart';

class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.collections_rounded,
              ),
              label: 'My TryOns',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_2_rounded,
              ),
              label: 'Me',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          onTap: (int index) {
            if (index == navigationShell.currentIndex) {
              final parentRoutes = ['/home', '/my_tryons', '/me'];
              context.go(parentRoutes[index]);
            } else {
              // Track tab switch event
              final tabNames = ['Home', 'My TryOns', 'Me'];
              AnalyticsHelper.trackTabSwitched(
                previousTabIndex: navigationShell.currentIndex,
                currentTabIndex: index,
                previousTabName: tabNames[navigationShell.currentIndex],
                currentTabName: tabNames[index],
              );
              navigationShell.goBranch(index);
            }
          },
        ),
      ),
      body: navigationShell,
    );
  }
}
