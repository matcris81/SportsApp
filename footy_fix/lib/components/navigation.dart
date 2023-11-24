import 'package:flutter/material.dart';
import 'package:footy_fix/screens/login_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:footy_fix/screens/account_page.dart';
// import 'package:footy_fix/screens/home.dart';
// import 'package:footy_fix/screens/search_page.dart';
// import 'package:footy_fix/screens/profile_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    GamesScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
              // rippleColor: Colors.grey[300]!,
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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Home Page'));
  }
}

class GamesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60), // Adjust the height as needed
          child: Container(
            padding: EdgeInsets.only(bottom: 10), // Adjust the bottom padding
            alignment: Alignment.bottomCenter,
            child: Text(
              'Games',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // API request to the backend to get the games
          print('API request sent to get the games');
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 20),
          children: const <Widget>[
            Center(child: Text('Games Page')),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Search Page'));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.only(top: 50), // Add padding at the top
          children: <Widget>[
            const ListTile(
              title: Center(
                // Wrap the Text widget with Center
                child: Text(
                  'name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make text bold
                  ),
                  textAlign: TextAlign.center, // Center align the text
                ),
              ),
            ),
            ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Account'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountScreen()),
                  );
                }),
            ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('Wallet'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }),
            ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }),
            ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }),
            ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }),
            ListTile(
                leading: const Icon(Icons.delete_forever_sharp),
                title: const Text('Delete account'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountScreen()),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
