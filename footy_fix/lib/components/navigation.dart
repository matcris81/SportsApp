import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/screens/start_screens/login_screen.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:footy_fix/screens/navigation_screens/home_screen.dart';
import 'package:footy_fix/screens/navigation_screens/games_screen.dart';
import 'package:footy_fix/screens/navigation_screens/search_screen.dart';
import 'package:footy_fix/screens/navigation_screens/more_info.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void signOutUser() async {
    await FirebaseAuth.instance.signOut();
    await PreferencesService().clearUserId();

    if (!mounted) return; // Check if the widget is still in the tree

    // Navigate to the login page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const HomeScreen(),
      const GamesScreen(),
      const SearchScreen(),
      ProfileScreen(
        onSignOut: signOutUser,
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              hoverColor: Colors.black,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.black,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.sports_soccer_rounded,
                  text: 'Games',
                ),
                GButton(
                  icon: Icons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: Icons.person_3_outlined,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
