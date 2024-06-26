class Data {
  final String name;
  final int type;
  final DateTime timeStamp;

  Data({
    required this.name,
    required this.type,
    required this.timeStamp,
  });

  // Factory method to create a Data object from JSON
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      name: json['name'],
      type: json['type'],
      timeStamp: DateTime.fromMillisecondsSinceEpoch(json['timeStamp'])
    );
  }

  // Method to convert a Data object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'timeStamp': timeStamp.millisecondsSinceEpoch,
    };
  }
}

class DataV2 {
  final String name;
  final String type;
  final DateTime timeStamp;

  DataV2({
    required this.name,
    required this.type,
    required this.timeStamp,
  });

  // Factory method to create a Data object from JSON
  factory DataV2.fromJson(Map<String, dynamic> json) {
    return DataV2(
      name: json['name'],
      type: json['type'],
      timeStamp: DateTime.fromMillisecondsSinceEpoch(json['timeStamp'])
    );
  }

  // Method to convert a Data object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'timeStamp': timeStamp.millisecondsSinceEpoch,
    };
  }
}

class AppEvent {
  final String type;
  final DateTime time;

  AppEvent({required this.type, required this.time});
}

class ScreenTime{
  int hour;
  int time;

  ScreenTime({required this.hour, required this.time});
}

Map<String, List<AppEvent>> parseEvents(List<Data> events) {

  Map<String, List<AppEvent>> appEvents = {};

  for (var event in events) {
    
    if(event.name.contains('android')){
      continue;
    }
    
    // Create or get the list of events for the app
    appEvents[event.name] ??= [];


    // Add the event type and its time to the list
    appEvents[event.name]!.add(AppEvent(
      type: eventTypeToString(event.type, event.name),
      time: event.timeStamp,
    ));
  }

  return appEvents;
}

List<DataV2> filterEvents(List<Data> events) {
  List<DataV2> filteredEvents = [];
  events.forEach((element) {
    String type = eventTypeToString(element.type, element.name);
    if(element.name.contains('android')){
      
    }
    else if(type == 'ACTIVITY_RESUMED' || type == 'ACTIVITY_PAUSED' || type == 'ACTIVITY_STOPPED'){
      filteredEvents.add(DataV2(name: element.name, type: type, timeStamp: element.timeStamp));
    }
  });
  return filteredEvents;
}

String eventTypeToString(int eventType, String eventName) {
  switch (eventType) {
    case 0:
      return 'NONE';
    case 1:
      return 'ACTIVITY_RESUMED';
    case 2:
      return 'ACTIVITY_PAUSED';
    case 5:
      return 'CONFIGURATION_CHANGE';
    case 7:
      return 'USER_INTERACTION';
    case 8:
      return 'SHORTCUT_INVOCATION';
    case 11:
      return 'STANDBY_BUCKET_CHANGED';
    case 15:
      return 'SCREEN_INTERACTIVE';
    case 16:
      return 'SCREEN_NON_INTERACTIVE';
    case 17:
      return 'KEYGUARD_SHOWN';
    case 18:
      return 'KEYGUARD_HIDDEN';
    case 19:
      return 'FOREGROUND_SERVICE_START';
    case 20:
      return 'FOREGROUND_SERVICE_STOP';
    case 23:
      return 'ACTIVITY_STOPPED';
    case 26:
      return 'DEVICE_SHUTDOWN';
    case 27:
      return 'DEVICE_STARTUP';
    default:
      //print('Unknown event type: $eventType for event: $eventName');
      return 'UNKNOWN_EVENT_TYPE';
  }
}