import 'package:fit_life/colors.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'package:flutter/services.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  static bool isAppbarHidden = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.white,
          splashColor: colors.orange,
          fontFamily: 'aptly'),
      home: Scaffold(
        appBar: isAppbarHidden ? null : const MainAppBar(),
        body: PageNavigator(updateLoginStatusForBar: _updateLoginStatusForBar,),
      ),
    );
  }

  void _updateLoginStatusForBar(bool status){
    setState(() {
      isAppbarHidden = !status;
    });
  }
}

// PageNavigator - STFUL widget deciding if logged in or not
class PageNavigator extends StatefulWidget {
  final Function(bool) updateLoginStatusForBar;
  const PageNavigator({super.key, required this.updateLoginStatusForBar});
  @override
  State<PageNavigator> createState() => _PageNavigatorState(updateLoginStatusForBar: updateLoginStatusForBar);
}

class _PageNavigatorState extends State<PageNavigator> {
  final Function(bool) updateLoginStatusForBar;
  bool isLoggedIn = false;

  _PageNavigatorState({required this.updateLoginStatusForBar});

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return Navigation(updateLoginStatus: _updateLoginStatus, updateLoginStatusForBar: updateLoginStatusForBar);
    }
    return LoginPage(updateLoginStatus: _updateLoginStatus, updateLoginStatusForBar: updateLoginStatusForBar,);
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
  final Function(bool) updateLoginStatusForBar;
  const Navigation({super.key, required this.updateLoginStatus, required this.updateLoginStatusForBar});

  @override
  State<Navigation> createState() => _NavigationState(updateLoginStatusForBar: updateLoginStatusForBar);
}

class _NavigationState extends State<Navigation> {
  int index = 0;
  late List<Widget> pages;
  final Function(bool) updateLoginStatusForBar;

  _NavigationState({required this.updateLoginStatusForBar});

  @override
  void initState() {
    super.initState();
    pages = [
      const Home(),
      const Tips(),
      Settings(updateLoginStatus: widget.updateLoginStatus, updateLoginStatusForBar: updateLoginStatusForBar),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.backgroundGrey,
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
  final Function(bool) updateLoginStatusForBar;
  const Settings({super.key, required this.updateLoginStatus, required this.updateLoginStatusForBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.backgroundGrey,
      child: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: OutlinedButton(
                onPressed: () {
                  logoutUser();
                  updateLoginStatusForBar(false);
                  updateLoginStatus(false);
                },
                style: buttonStyle,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.logout,
                      color: colors.orange,
                      size: 40,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(color: colors.orange, fontSize: 30),
                    ),
                  ],
                ),
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
      backgroundColor: colors.titleBlack,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: colors.orange,
      unselectedItemColor: colors.lightShadow,
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
  final Function(bool) updateLoginStatusForBar;

  const LoginPage({
    super.key,
    required this.updateLoginStatus,
    required this.updateLoginStatusForBar
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.backgroundGrey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/cliff.jpg',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 0),
                      child: const Image(
                        image: AssetImage('assets/logo_black_noText.png'),
                        color: colors.loginPageColorOpacity,
                        height: 450,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 150),
                      child: Column(
                        children: [
                          const Text(
                            'Life tuner',
                            style: TextStyle(
                                fontSize: 80,
                                color: colors.loginPageColor,
                                fontWeight: FontWeight.w800),
                          ),
                          Container(
                            width: 300,
                            height: 10,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: colors.loginPageColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                color: colors.loginPageColor),
                          ),
                          const Text(
                            'Live your life',
                            style: TextStyle(
                                fontSize: 50,
                                color: colors.loginPageColor,
                                fontWeight: FontWeight.w800),
                          ),
                          Container(
                            height: 400,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              bool success = await loginUser();
                              updateLoginStatusForBar(success);
                              updateLoginStatus(success);
                            },
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all<Size>(
                                const Size(280, 120)
                              ),
                              backgroundColor: const MaterialStatePropertyAll<Color>(colors.whiteOpacity)
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image(image: AssetImage('assets/google_logo.png'), width: 50),
                                Text(
                                  'Login',
                                  style: TextStyle(color: colors.lightShadow, fontSize: 60),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
  });

  @override
  get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Center(
          child: Text(
        "Fit Life",
        style: TextStyle(color: colors.orange),
      )),
      backgroundColor: colors.titleBlack,
    );
  }
}

final ButtonStyle buttonStyle = OutlinedButton.styleFrom(
  backgroundColor: colors.lightShadow,
  side: const BorderSide(color: colors.orange, width: 2),
  fixedSize: const Size(200, 70)
);
