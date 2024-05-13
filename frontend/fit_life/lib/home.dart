import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'health.dart' as health;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'steps.dart';
import 'package:intl/intl.dart';
import 'colors.dart';

const methodChannel = MethodChannel('kotlinChannel');
health.health healthFactory = health.health();
List<StepData> data = <StepData>[];



  

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  @override
  void initState() {

    super.initState();
/*
    _listener = AppLifecycleListener(
      onDetach: () => server.Connection.steps(),
      onRestart: () => server.Connection.steps(),
      onHide: () => server.Connection.steps(),
      onPause: () => server.Connection.steps(),
      onInactive: () => server.Connection.steps(),
    );
*/

    getUsageStats();

  }
Future<void> getUsageStats() async {
  try {
    var usageStats = await methodChannel.invokeMethod('getUsageStats');

      
    print('Usage stats: $usageStats');
  } 
  on PlatformException catch (e) {
    print("Failed to get usage stats: '$e'.");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: colors.backgroundGrey,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Graph(),
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
  void initState(){
    super.initState();
    _dataFuture = healthFactory.getStepsFromLastDay();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StepData>>(
      future: _dataFuture,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Placeholder();
        }
        else if(snapshot.hasError){
          return Text('Error: ${snapshot.error}');
        }
        else{
          _data = snapshot.data!;
          return SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              labelStyle: TextStyle(color: colors.white),
            ),
            primaryYAxis: const NumericAxis(
              labelStyle: TextStyle(color: colors.white),
              
              majorGridLines: MajorGridLines(
                width: 1,
              ),
              minorGridLines: MinorGridLines(
                width: 1,
                color: colors.whiteSmallOpacity
              ),
              minorTicksPerInterval: 1,
            ),
            legend: const Legend(isVisible: false),
            tooltipBehavior: TooltipBehavior(enable: true),
            palette: const [colors.orange],
            series: <CartesianSeries<StepData, String>>[
              ColumnSeries<StepData, String>(
                  dataSource: _data,
                  xValueMapper: (StepData steps, _) => DateFormat.Hm().format(steps.time).toString(),
                  yValueMapper: (StepData steps, _) => steps.steps,
                  animationDuration: 2000,
                  name: 'Steps',
                  dataLabelSettings: const DataLabelSettings(isVisible: true, 
                    labelAlignment: ChartDataLabelAlignment.top, 
                    offset: Offset(0, 20),
                    color: colors.lightShadow,
                    showZeroValue: false,
                    alignment: ChartAlignment.far,
                    )),
            ]);
        }
      },
      
    );
    
  }
}


