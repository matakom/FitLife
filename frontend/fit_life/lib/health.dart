import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class health{

  Future<void> healthTest() async{
    
    var now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    
    int? steps = await getSteps(now, midnight);

    print('steps: $steps');
  }
  Future<int?> getSteps(DateTime startTime, DateTime endTime) async{
    if(!await Permission.activityRecognition.isGranted){
      await Permission.activityRecognition.request();
    }

    Health().configure(useHealthConnectIfAvailable: true);

    var types = [
      HealthDataType.STEPS,
    ];

    await Health().requestAuthorization(types);

    var now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day);
    return await Health().getTotalStepsInInterval(midnight, now) ?? -1;
  }

}