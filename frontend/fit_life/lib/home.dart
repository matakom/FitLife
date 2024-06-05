import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'health.dart' as health;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'steps.dart';
import 'package:intl/intl.dart';
import 'colors.dart';
import 'data.dart';
import 'appData.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

const methodChannel = MethodChannel('kotlinChannel');
health.health healthFactory = health.health();


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Duration interactive = Duration.zero;

  @override
  void initState() {
    super.initState();
    getUsageStats();
  }

  Future<void> getUsageStats() async {
    try {
      List<dynamic> jsonList =
          jsonDecode(await methodChannel.invokeMethod('getUsageStats'));

      appData.dataList = jsonList.map((json) => Data.fromJson(json)).toList();

      appData.sortedEvents = parseEvents(appData.dataList);

      int milliSeconds = 0;
      int previousTimeStamp = -1;

      appData.dataList.forEach((element) {
        if (element.type == 15 || element.type == 16) {
          if (element.type == 15) {
            previousTimeStamp = element.timeStamp.millisecondsSinceEpoch;
          } else if (previousTimeStamp != -1) {
            milliSeconds +=
                element.timeStamp.millisecondsSinceEpoch - previousTimeStamp;
            previousTimeStamp = -1;
          }
        }
      });

      if (previousTimeStamp != -1) {
        milliSeconds +=
            DateTime.now().millisecondsSinceEpoch - previousTimeStamp;
      }

      setState(() {
        interactive = Duration(milliseconds: milliSeconds);
      });

      print("-------------------------");
      print("Interactive: ${interactive.toString()}");
      print("-------------------------");
      print("LENGTH: ${appData.dataList.length}");
      print("-------------------------");

      Map<String, int> timeMap = {};

      appData.sortedEvents.forEach((key, value) {
        int start = -1;
        value.forEach((element) {
          if (element.type == "ACTIVITY_RESUMED" && start == -1) {
            start = element.time.millisecondsSinceEpoch;
          } else if ((element.type == "ACTIVITY_STOPPED") && start != -1) {
            timeMap[key] = element.time.millisecondsSinceEpoch - start + (timeMap[key] ?? 0);
            start = -1;
          }
        });
        if (start != -1) {
          timeMap[key] = DateTime.now().millisecondsSinceEpoch -
              start +
              (timeMap[key] ?? 0);
        }
      });

      List mapKeys = timeMap.keys.toList(growable: false);
      mapKeys.sort((a, b) => timeMap[b]!.compareTo(timeMap[a]!));
      appData.sortedTimeMap = LinkedHashMap();
      mapKeys.forEach((key) => appData.sortedTimeMap[key] = timeMap[key]);

      for (var key in appData.sortedTimeMap.keys) {
        appData.sortedTimeMapWidgets.add(
          ScreenTimeFrame(
              name: key,
              time: '${Duration(milliseconds: appData.sortedTimeMap[key])
                      .inHours
                      .toString()
                      .padLeft(2, '0')}:${(Duration(milliseconds: appData.sortedTimeMap[key]).inMinutes % 60)
                      .toString()
                      .padLeft(2, '0')}:${(Duration(milliseconds: appData.sortedTimeMap[key]).inSeconds % 60)
                      .toString()
                      .padLeft(2, '0')}'),
        );
      }
    } on PlatformException catch (e) {
      print("Failed to get usage stats: '$e'.");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: colors.backgroundGrey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Steps',
                    style: TextStyle(color: colors.white, fontSize: 30),
                  ),
                ),
                const Graph(),
                lineDivider(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'Screen time: ${interactive.inHours.toString().padLeft(2, '0')}:${interactive.inMinutes.remainder(60).toString().padLeft(2, '0')}:${interactive.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: colors.white, fontSize: 30),
                  ),
                ),
                ...appData.sortedTimeMapWidgets
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget lineDivider() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 10.0),
    child: Divider(
      color: colors.whiteSmallOpacity,
      thickness: 1,
    ),
  );
}

class ScreenTimeFrame extends StatefulWidget {
  final String name;
  final String time;

  const ScreenTimeFrame({super.key, required this.name, required this.time});

  @override
  State<ScreenTimeFrame> createState() => _ScreenTimeFrameState();
}

class _ScreenTimeFrameState extends State<ScreenTimeFrame> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            border: Border.all(color: colors.orange),
            color: colors.titleBlack,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Text(widget.name,
                      style:
                          const TextStyle(fontSize: 20, color: colors.white)),
                  Text(widget.time,
                      style:
                          const TextStyle(fontSize: 16, color: colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Graph extends StatefulWidget {
  const Graph({super.key});

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  Future<List<StepData>>? _dataFuture;
  late List<StepData> _data;

  @override
  void initState() {
    super.initState();
    _dataFuture = healthFactory.getStepsFromLastDay();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StepData>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if(appData.data.isEmpty){
            return Padding(
              padding: const EdgeInsets.all(100.0),
              child: LoadingAnimationWidget.inkDrop(color: colors.orange, size: 50),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
            child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  labelStyle: TextStyle(color: colors.white),
                ),
                primaryYAxis: const NumericAxis(
                  labelStyle: TextStyle(color: colors.white),
                  majorGridLines: MajorGridLines(
                    width: 1,
                  ),
                  minorGridLines:
                      MinorGridLines(width: 1, color: colors.whiteSmallOpacity),
                  minorTicksPerInterval: 1,
                ),
                legend: const Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true),
                palette: const [
                  colors.orange
                ],
                series: <CartesianSeries<StepData, String>>[
                  ColumnSeries<StepData, String>(
                      dataSource: appData.data,
                      xValueMapper: (StepData steps, _) =>
                          DateFormat.Hm().format(steps.time).toString(),
                      yValueMapper: (StepData steps, _) => steps.steps,
                      animationDuration: 0,
                      name: 'Steps',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                        offset: Offset(0, 20),
                        color: colors.lightShadow,
                        showZeroValue: false,
                        alignment: ChartAlignment.far,
                      )),
                ]),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
            child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  labelStyle: TextStyle(color: colors.white),
                ),
                primaryYAxis: const NumericAxis(
                  labelStyle: TextStyle(color: colors.white),
                  majorGridLines: MajorGridLines(
                    width: 1,
                  ),
                  minorGridLines:
                      MinorGridLines(width: 1, color: colors.whiteSmallOpacity),
                  minorTicksPerInterval: 1,
                ),
                legend: const Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true),
                palette: const [
                  colors.orange
                ],
                series: <CartesianSeries<StepData, String>>[
                  ColumnSeries<StepData, String>(
                      dataSource: _data,
                      xValueMapper: (StepData steps, _) =>
                          DateFormat.Hm().format(steps.time).toString(),
                      yValueMapper: (StepData steps, _) => steps.steps,
                      animationDuration: 0,
                      name: 'Steps',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.top,
                        offset: Offset(0, 20),
                        color: colors.lightShadow,
                        showZeroValue: false,
                        alignment: ChartAlignment.far,
                      )),
                ]),
          );
        }
      },
    );
  }
}
