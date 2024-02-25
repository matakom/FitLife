import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Connection{
  static const String serverIp = '192.168.180.109';
  static const String serverIpHome = '192.168.1.111';
  static const int port = 80;
  static late HttpClient client;

  static void login(String mail, String name) async{
    if(mail == '' || name == ''){
      throw Exception('Is null and should not be');
    }
    
    client = HttpClient();

    try{
      HttpClientRequest request = await client.post(serverIpHome, port, '/login');

      String jsonData = '{"mail": "$mail", "name": "$name"}';
      int contentLength = utf8.encode(jsonData).length;
      request.headers.add(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add(HttpHeaders.contentLengthHeader, contentLength.toString());
      request.write(jsonData);

      HttpClientResponse response = await request.close();

      final data = await response.transform(utf8.decoder).join();
      print(data);
      client.close();
    }
    catch(error){
      print(error.toString());
    }    

    final Uri url = Uri.http(serverIpHome, '');

    var response = await http.post(url);

    print('response: ${response.body}');
  }

  static void test() async{

    client = HttpClient();

    try{
      HttpClientRequest request = await client.post(serverIpHome, port, '');

    String jsonData = '{"type": "steps", "count": "5000", "startTime": "morning", "endTime": "now"}';
      int contentLength = utf8.encode(jsonData).length;
      request.headers.add(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      request.headers.add(HttpHeaders.contentLengthHeader, contentLength.toString());
      request.write(jsonData);

      HttpClientResponse response = await request.close();

      final data = await response.transform(utf8.decoder).join();
      print(data);
    }
    finally{
      client.close();
    }

    final Uri url = Uri.http(serverIpHome, '');

    var response = await http.post(url);

    print('response: ${response.body}');
  }

}
