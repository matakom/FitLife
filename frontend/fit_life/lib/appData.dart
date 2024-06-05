import 'dart:collection';
import 'package:fit_life/steps.dart';
import 'package:flutter/material.dart';
import 'data.dart';

class appData{
  static List<StepData> data = <StepData>[];
  static List<Data> dataList = <Data>[];
  static Map<String, List<AppEvent>> sortedEvents = <String, List<AppEvent>>{};
  static LinkedHashMap sortedTimeMap = LinkedHashMap();
  static List<Widget> sortedTimeMapWidgets = <Widget>[];
}