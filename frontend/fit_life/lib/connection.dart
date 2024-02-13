import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Connection{
  static const String serverIp = '192.168.1.111';
  static const int port = 80;
  static const String path = '';
  static late HttpClient client;

  static void test() async{

    client = HttpClient();

    try{
      print("Sending data...");
      HttpClientRequest request = await client.get(serverIp, port, path);

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
