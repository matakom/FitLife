import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home.dart';
//import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        appBar: MainAppBar(),
        body: PageNavigator(),
      ),
    );
  }
}

// PageNavigator - STFUL widget deciding if logged in or not
class PageNavigator extends StatefulWidget {
  const PageNavigator({super.key});
  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return Navigation(updateLoginStatus: _updateLoginStatus);
    }
    return LoginPage(updateLoginStatus: _updateLoginStatus);
  }

  void _updateLoginStatus(bool status) {
    setState(() {
      isLoggedIn = status;
    });
  }
}

// Navigation - STFUL widget for changing pages when logged in
class Navigation extends StatefulWidget {
  final Function(bool) updateLoginStatus;
  const Navigation({super.key, required this.updateLoginStatus});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int index = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const Home(),
      const Tips(),
      Settings(updateLoginStatus: widget.updateLoginStatus),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGrey,
      child: Scaffold(
        body: pages[index],
        bottomNavigationBar: BottomNavBar(updateIndex: _updateIndex),
      ),
    );
  }

  void _updateIndex(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }
}

class Tips extends StatelessWidget {
  const Tips({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Settings extends StatelessWidget {
  final Function(bool) updateLoginStatus;
  const Settings({super.key, required this.updateLoginStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGrey,
      child: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: OutlinedButton(
                onPressed: () {
                  logoutUser();
                  updateLoginStatus(false);
                },
                style: buttonStyle,
                child: const Text('Logout', style: TextStyle(color: orange),),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  final Function(int) updateIndex;
  const BottomNavBar({super.key, required this.updateIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      backgroundColor: titleBlack,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: orange,
      unselectedItemColor: lightShadow,
      onTap: (x) {
        setState(() {
          index = x;
        });
        widget.updateIndex(index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.tips_and_updates), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
      ],
    );
  }
}

// LoginPage - STLES widget for login screen
class LoginPage extends StatelessWidget {
  final Function(bool) updateLoginStatus;

  const LoginPage({
    super.key,
    required this.updateLoginStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGrey,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: const Text(
                'Login before using Fit Life',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: orange),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: OutlinedButton(
                onPressed: () async {
                  bool success = await loginUser();
                  updateLoginStatus(success);
                },
                style: buttonStyle,
                child: const Text(
                  "Login with google account",
                  style: TextStyle(color: orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Center(child: Text("Fit Life", style: TextStyle(color: orange),)),
      backgroundColor: titleBlack,
    );
  }
}

final ButtonStyle buttonStyle = OutlinedButton.styleFrom(
  backgroundColor: lightShadow,
  side: const BorderSide(color: orange, width: 2),
);

const titleBlack = Color(0xff121212);
const backgroundGrey = Color(0xff232323);
const lightShadow = Color(0xff3D3C3C);
const orange = Color(0xffFF9D00);
