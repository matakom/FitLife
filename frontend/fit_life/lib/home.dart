import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'health.dart' as health;

const methodChannel = MethodChannel('kotlinChannel');

Future<void> getUsageStats() async {
  try {
    final Map<dynamic, dynamic> usageStats = await methodChannel.invokeMethod('getUsageStats');
    print('Usage stats: $usageStats');
  } 
  on PlatformException catch (e) {
    print("Failed to get usage stats: '${e.message}'.");
  }
}

  

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {



  @override
  void initState() {

    super.initState();
/*
    _listener = AppLifecycleListener(
      onDetach: () => server.Connection.steps(),
      onRestart: () => server.Connection.steps(),
      onHide: () => server.Connection.steps(),
      onPause: () => server.Connection.steps(),
      onInactive: () => server.Connection.steps(),
    );
*/

    getUsageStats();

    health.health healthFactory = health.health();
    healthFactory.healthTest();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: Colors.amber[300],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('a'
                ),
              ],
            ),
          ),
        ),
    );
  }
}

