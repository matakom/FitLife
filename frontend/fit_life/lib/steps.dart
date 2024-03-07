import 'package:flutter/foundation.dart';

class Steps extends ChangeNotifier{
  static int steps = 0;

  static int getSteps(){
    return steps;
  }

  static void addSteps(int tempSteps){
    steps += tempSteps;
  }
  static void resetSteps(){
    steps = 0;
  }
}