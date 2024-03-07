import 'package:fit_life/steps.dart';
import 'package:flutter/material.dart';
import 'connection.dart' as server;
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'steps.dart' as stepCounter;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _state = '';
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  //late final AppLifecycleListener _listener;

  @override
  void initState() {

    super.initState();

    initPlatformState();

/*
    _listener = AppLifecycleListener(
      onDetach: () => server.Connection.steps(),
      onRestart: () => server.Connection.steps(),
      onHide: () => server.Connection.steps(),
      onPause: () => server.Connection.steps(),
      onInactive: () => server.Connection.steps(),
    );
*/

    // Counters bug - every new build it gets one more step
    Steps.addSteps(-1);

    if(this.mounted){
      setState(() {
        Steps.steps = Steps.steps;
      });
    }

  }

  @override
  void dispose(){
    //_listener.dispose();
    super.dispose();
  }

  // Handle step count changed
  void onStepCount(StepCount event) {
    Steps.addSteps(1);
    if(this.mounted){
      setState(() {
        Steps.steps = Steps.steps;
      });
    }
  }

  // Handle status changed
  void onPedestrianStatusChanged(PedestrianStatus event) {
    if(this.mounted){
      setState(() {
        _state = event.status;
      });
    }
  }

  // Handle the error
  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
  }

  // Handle the error
  void onStepCountError(error) {
    print('onStepCountError: $error');
  }

  void initPlatformState() async {
    _pedestrianStatusStream = await Pedometer.pedestrianStatusStream;
    _stepCountStream = await Pedometer.stepCountStream;

    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: Colors.amber[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Steps: ${stepCounter.Steps.steps}',
                  style: const TextStyle(fontSize: 40),
                ),
                Text(
                  'State: $_state',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

