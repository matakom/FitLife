import 'dart:convert';
import 'dart:io';
import 'steps.dart' as stepsCounter;
import 'package:intl/intl.dart';
import 'preferences.dart' as preferences;

class Connection{
  static const String ipAddress = '10.0.3.101';
  static const int port = 80;
  static late HttpClient client;

  static void login(String mail, String name) async{
    if(mail == '' || name == ''){
      throw Exception('Is null and should not be');
    }
    print('login request');    
    client = HttpClient();

    try{
      HttpClientRequest request = await client.post(ipAddress, port, '/login');

      String jsonData = '{"mail": "$mail", "name": "$name"}';
      int contentLength = utf8.encode(jsonData).length;
      request.headers.add(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add(HttpHeaders.contentLengthHeader, contentLength.toString());
      request.write(jsonData);

      HttpClientResponse response = await request.close();

      final data = await response.transform(utf8.decoder).join();
      print('Response: $data');
      client.close();
    }
    catch(error){
      print(error.toString());
    }    
  }

  static Future<void> steps() async{

    client = HttpClient();
    try{
      HttpClientRequest request = await client.post(ipAddress, port, '/newKnownActivity');

      final DateFormat format = DateFormat('MM/dd/yyyy');

      //String jsonData = '{"activity": "steps", "count": "${stepsCounter.Steps.getSteps()}", "startTime": "${format.format(DateTime.now())} 00:00:00", "endTime": "${format.format(DateTime.now().add( const Duration(days: 1)))} 00:00:00", "user": "${preferences.Preferences.getMail()}"}';
      String jsonData = '{"activity": "steps", "count": "${stepsCounter.Steps.getSteps()}", "startTime": "${format.format(DateTime.now())} 00:00:00", "endTime": "${format.format(DateTime.now().add( const Duration(days: 1)))} 00:00:00", "user": "mata.komarek@gmail.com"}';
      int contentLength = utf8.encode(jsonData).length;
      request.headers.add(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add(HttpHeaders.contentLengthHeader, contentLength.toString());
      request.write(jsonData);

      HttpClientResponse response = await request.close();

      final data = await response.transform(utf8.decoder).join();
      print('Response: $data');
    }
    finally{
      client.close();
    }
  }
  static void getSteps() async{

    client = HttpClient();
    int steps = 0;
    try{
      HttpClientRequest request = await client.get(ipAddress, port, '/getSteps');

      final DateFormat format = DateFormat('MM/dd/yyyy');

      String jsonData = '{"time": "${format.format(DateTime.now())} 00:00:00", "user": "${preferences.Preferences.getMail()}"}';
      int contentLength = utf8.encode(jsonData).length;
      request.headers.add(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add(HttpHeaders.contentLengthHeader, contentLength.toString());
      request.write(jsonData);

      HttpClientResponse response = await request.close();

      final data = await response.transform(utf8.decoder).join();

      steps = int.parse(data);

      print('Response: $data');
    }
    finally{
      client.close();
    }

    stepsCounter.Steps.addSteps(steps);

  }
}
