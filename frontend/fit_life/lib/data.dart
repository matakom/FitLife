import 'dart:convert';

class Data {
  final String name;
  final int type;
  final int timeStamp;

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
      timeStamp: json['timeStamp'],
    );
  }

  // Method to convert a Data object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'timeStamp': timeStamp,
    };
  }
}