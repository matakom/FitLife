import 'package:fit_life/steps.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'steps.dart' as steps_counter;
import 'package:flutter/services.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';

const methodChannel = MethodChannel('kotlinChannel');

Future<void> getUsageStats() async {
  try {
    print('before getting usage data');
    final Map<dynamic, dynamic> usageStats = await methodChannel.invokeMethod('getUsageStats');
    print('Usage stats: $usageStats');
  } 
  on PlatformException catch (e) {
    print("Failed to get usage stats: '${e.message}'.");
  }
}

Future<void> healthTest() async{

  //android/app/build.gradle dependencies finish

  bool readOnly = true;

  List<HealthConnectDataType> types = [
    HealthConnectDataType.Steps,
  ];

  var startTime = DateTime.now().subtract(const Duration(days: 4));
  var endTime = DateTime.now();

  print('isApiSupported: ${await HealthConnectFactory.isApiSupported()}');
  print('isAvailable: ${await HealthConnectFactory.isAvailable()}');
  //await HealthConnectFactory.installHealthConnect();
  //HealthConnectFactory.openHealthConnectSettings();
  print('hasPermissions: ${await HealthConnectFactory.hasPermissions(types, readOnly: readOnly,)}');
  await HealthConnectFactory.requestPermissions(types, readOnly: readOnly,);
  print('hasPermissions: ${await HealthConnectFactory.hasPermissions(types, readOnly: readOnly,)}');
  try{
    var results = await HealthConnectFactory.getRecord(type: types.first ,startTime: startTime,endTime: endTime,);
    print('Results: $results');
  } on Exception catch (e){
    print("Exception: $e");
  }



}

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

    if(mounted){
      setState(() {
        Steps.steps = Steps.steps;
      });
    }

    getUsageStats();

    healthTest();



  }

  @override
  void dispose(){
    //_listener.dispose();
    super.dispose();
  }

  // Handle step count changed
  void onStepCount(StepCount event) {
    Steps.addSteps(1);
    if(mounted){
      setState(() {
        Steps.steps = Steps.steps;
      });
    }
  }

  // Handle status changed
  void onPedestrianStatusChanged(PedestrianStatus event) {
    if(mounted){
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
  void onStepsCounterError(error) {
    print('onStepsCounterError: $error');
  }

  void initPlatformState() async {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(onStepCount).onError(onStepsCounterError);

    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);

    permission.Permission.activityRecognition.request();
    permission.Permission.sensors.request();


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
                  'Steps: ${steps_counter.Steps.steps}',
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

