import 'package:earthquake_warning/accelerometer_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AppProvider extends ChangeNotifier{
  AccelerometerData _data = AccelerometerData("0", "0", "0");
  AccelerometerData get data => _data;

  void setAccelerometerData(AccelerometerData data){
    _data = data;
    notifyListeners();
  }

  void getSensorsData(){
    userAccelerometerEvents.listen(
          (UserAccelerometerEvent event) {
        setAccelerometerData(AccelerometerData(event.x.toString(), event.y.toString(), event.z.toString()));
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );
  }

}