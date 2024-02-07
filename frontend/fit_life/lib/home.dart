import 'package:flutter/material.dart';
import 'package:health/health.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {

    MyHealth myHealth = MyHealth();
    myHealth.GetSteps();

    return const Placeholder();
  }
}

class MyHealth {

  Future<void> GetSteps() async{

    int? steps;

    HealthFactory health = HealthFactory();

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

    print(steps);

  }

}