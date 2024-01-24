import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Fit Life")),
          backgroundColor: Colors.amber[800],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              const SizedBox(
                height: 60,
              ),
              const Text('Login before using Fit Life',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 60,
              ),
              ElevatedButton(
                onPressed: loginUser, 
                style: amberButtonStyle,
                child: const Text("Login with google account",
                  style: TextStyle(
                    color: Colors.black
                  ),),
              ),
            ]
          ),
        ),
        backgroundColor: Colors.amber[300],
      ),
    );
  }
}

final ButtonStyle amberButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.amber[800],
);

DateTime convertNanosecondsToDateTime(int nanoseconds)
{
  print('convertNanosecondsToDateTime');
  // Nanoseconds to microseconds
  int microSeconds = nanoseconds ~/ 100;

  // Create a DateTime object from the ticks
  DateTime dateTime = DateTime.utc(1970, 1, 1, 0, 0, 0).add(Duration(microseconds: microSeconds));

  return dateTime;
}