import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'connection.dart' as server;
import 'package:flutter_health_connect/flutter_health_connect.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {

    MyHealth myHealth = MyHealth();
    Future<int?> steps = myHealth.getSteps();

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
  Future<int?> getSteps() async {
    int? steps;

    HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

    var types = [
      HealthDataType.STEPS,
    ];

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    var permissions = [
      HealthDataAccess.READ,
    ];

    await health.requestAuthorization(types, permissions: permissions);

    steps = await health.getTotalStepsInInterval(midnight, now);

    print('Steps: $steps');

    return steps;

    
  }
}
