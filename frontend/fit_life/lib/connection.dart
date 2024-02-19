import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Connection{
  static const String serverIp = '192.168.180.109';
  static const int port = 80;
  static const String path = '';
  static late HttpClient client;

  static void test() async{

    client = HttpClient();

    try{
      print("Sending data...");
      HttpClientRequest request = await client.post(serverIp, port, path);

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

    final Uri url = Uri.http(serverIp, '');

    print(url.port);
    print(url.authority);

    var response = await http.post(url);

    print('response: ${response.body}');
    print('response code: ${response.statusCode}');
  }

}
