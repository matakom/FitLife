import 'package:fit_life/appData.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class Tips extends StatefulWidget {
  const Tips({super.key});

  @override
  State<Tips> createState() => _TipsState();
}

class _TipsState extends State<Tips> {
  @override
  Widget build(BuildContext context) {
    appData.tips = [];

    // Less screen time
    if(appData.interactive > const Duration(hours: 2)){
      appData.tips.add(
        tipCard(name: tipList[0]['name'] ?? 'Unknown', description: tipList[0]['description'] ?? 'Unknown'),
      );
    }

    // Breaks
    if(appData.screenTimeDetailed.any((element) => element.time / 1000 / 60 > 55)){
      appData.tips.add(
        tipCard(name: tipList[1]['name'] ?? 'Unknown', description: tipList[1]['description'] ?? 'Unknown'),
      );
    }

    // Steps
    int steps = 0;
    appData.data.forEach((element) {
      steps += element.steps;
    });
    if(steps < 10000){
      appData.tips.add(
        tipCard(name: tipList[2]['name'] ?? 'Unknown', description: tipList[2]['description'] ?? 'Unknown'),
      );
    }

    // Screen time before bed
    int length = appData.screenTimeDetailed.length - 2;
    print(appData.screenTimeDetailed[length].hour);
    print((appData.screenTimeDetailed[length].time));
    if(appData.screenTimeDetailed[length].hour == 22 || appData.screenTimeDetailed[length].hour == 23){
      if((appData.screenTimeDetailed[length].time / 1000 / 60 )> 5){
        appData.tips.add(
          tipCard(name: tipList[3]['name'] ?? 'Unknown', description: tipList[3]['description'] ?? 'Unknown'),
        );
      }
    }

    // Early sunlight
    DateTime now = DateTime.now();
    if(!appData.data.any((element) => element.steps > 500 && element.time.millisecondsSinceEpoch < now.subtract(Duration(hours: now.hour, minutes: now.minute)).add(const Duration(hours: 10)).millisecondsSinceEpoch)){
      appData.tips.add(
        tipCard(name: tipList[4]['name'] ?? 'Unknown', description: tipList[4]['description'] ?? 'Unknown'),
      );
    }

    // Active hours
    int numberOfActiveHours = 0;
    appData.data.where((element) => element.steps > 1000).forEach((element) {
      numberOfActiveHours++;
    });
    if(numberOfActiveHours < 6){
      appData.tips.add(
        tipCard(name: tipList[5]['name'] ?? 'Unknown', description: tipList[5]['description'] ?? 'Unknown'),
      );
    }
    
    // No tips
    if(appData.tips.isEmpty){
      appData.tips.add(
        tipCard(name: tipList[6]['name'] ?? 'Unknown', description: tipList[6]['description'] ?? 'Unknown'),
      );
    }




    return Container(
      color: colors.backgroundGrey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              ...appData.tips
            ]
          ),
        ),
      ),
    );
  }
}

class tipCard extends StatefulWidget {
  const tipCard({super.key, required this.name, required this.description});

  final String name;
  final String description;

  @override
  State<tipCard> createState() => _tipCardState();
}

class _tipCardState extends State<tipCard> {
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
                  Text(widget.description,
                  textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 16, color: colors.white, )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const tipList = [
  {
    "name": "Less screen time",
    "description": "Use your phone less. Healthy amount is under 2 hours a day."
  },
  {
    "name": "Take Frequent Breaks",
    "description": "It is recommended to take 5 - 10 minute break each hour."
  },
  {
    "name": "Stay Active",
    "description": "Walking 10 000 steps each keep helps to keep your body healthy."
  },
  {
    "name": "Bedtime Screen-Free Zone",
    "description": "Avoid screens at least one hour before bed to improve sleep quality."
  },
  {
    "name": "Get sunlight early",
    "description": "You should go for a walk at the morning to get sunlight. It helps to wake you up."
  },
  {
    "name": "Active hours",
    "description": "You should walk 1000 steps at least 6 hours every day."
  },
  {
    "name": "You are good",
    "description": "We have no tips for you right now. Check later!"
  }


];