import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'connection.dart' as server;
import 'package:network_info_plus/network_info_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {

    MyHealth myHealth = MyHealth();
    Future<int?> steps = myHealth.GetSteps();

    server.Connection.test();

    return FutureBuilder<int?>(
      future: steps,
      builder: (context, snapshot){
        if(snapshot.hasData){
          return Container(
            color: Colors.amber[300],
            child: Center(
              child: Text('Steps: ${snapshot.data}'),
            ),
          );
        }
        else if(snapshot.hasError){
          return Container(
            color: Colors.amber[300],
            child: Center(
              child: Text('Steps: ${snapshot.error}'),
            ),
          );
        }
        else{
          return Container(
            color: Colors.amber[300],
            child: const Center(
              child: Text('Loading steps'),
            ),
          );
        }
      },
    );
  }
}

class MyHealth {
  Future<int?> GetSteps() async {
    int? steps;

    HealthFactory health = HealthFactory();

    var types = [
      HealthDataType.STEPS,
    ];

    final now = DateTime.now();
    final thisYear = DateTime(2024, 1, 16);
    final midnight = DateTime(now.year, now.month, now.day);

    var permissions = [
      HealthDataAccess.READ,
    ];

    await health.requestAuthorization(types, permissions: permissions);

    steps = await health.getTotalStepsInInterval(midnight, now);

    print('Steps: $steps');

    final info = NetworkInfo();

    String? ip = await info.getWifiIP();
    print(ip);

    return steps;

    
//10.0.0.156
//192.168.1.111
  }
}
