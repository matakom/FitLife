import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'steps.dart';
import 'appData.dart';

class health{

  Future<int> getSteps(DateTime startTime, DateTime endTime) async{
    return await Health().getTotalStepsInInterval(startTime, endTime) ?? -1;
  }
  Future<List<StepData>> getStepsFromLastDay() async{

    if(!await Permission.activityRecognition.isGranted){
      await Permission.activityRecognition.request();
    }

    Health().configure(useHealthConnectIfAvailable: true);

    var types = [
      HealthDataType.STEPS,
    ];

    if (!((await Health().hasPermissions(types)) ?? false)) {
      await Health().requestAuthorization(types);
    }
    List<StepData> data = <StepData>[];

    DateTime today = DateTime.now().subtract(Duration(days: 0));
    today = today.subtract(Duration(hours: today.hour, minutes: today.minute, seconds: today.second, milliseconds: today.millisecond, microseconds: today.microsecond));

    int interval = 60;

    for(int i = 0; i < 24 * 60 / interval; i++){
      DateTime startTime = today.add(Duration(minutes: i * interval));
      DateTime endTime = startTime.add(Duration(minutes: interval));
      data.add(StepData(await getSteps(startTime, endTime), startTime));
    }

    // Cut it from beginning
    for(int i = 0; i < data.length - 1; i++){
      if(data[i].steps != 0){
        for(int j = i - 2; j >= 0; j--){
          data.removeAt(j);
        }
        break;
      }
    }

    // Cut it from end
    for(int i = data.length - 1; i >= 0; i--){
      if(data[i].steps != 0){
        for(int j = i + 2; j < data.length; ){
          data.removeAt(j);
        }
        break;
      }
    }

    appData.data = data;
    return data;
  }

}
