import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'steps.dart';

class health{

  Future<void> healthTest() async{
    
    var now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    
    int? steps = await getSteps(now, midnight);

    print('steps: $steps');
  }
  Future<int> getSteps(DateTime startTime, DateTime endTime) async{
    if(!await Permission.activityRecognition.isGranted){
      await Permission.activityRecognition.request();
    }

    Health().configure(useHealthConnectIfAvailable: true);

    var types = [
      HealthDataType.STEPS,
    ];

    await Health().requestAuthorization(types);

    return await Health().getTotalStepsInInterval(startTime, endTime) ?? -1;
  }
  Future<List<StepData>> getStepsFromLastDay() async{

    List<StepData> data = <StepData>[];

    DateTime today = DateTime.now().subtract(Duration(days: 1));
    today = today.subtract(Duration(hours: today.hour, minutes: today.minute, seconds: today.second, milliseconds: today.millisecond, microseconds: today.microsecond));

    int interval = 60;

    print(today);

    for(int i = 0; i < 24 * 60 / interval; i++){
      DateTime startTime = today.add(Duration(minutes: i * interval));
      DateTime endTime = startTime.add(Duration(minutes: interval));
      print(startTime);
      print(endTime);
      data.add(StepData(await getSteps(startTime, endTime), startTime));
    }

    return data;
  }

}
