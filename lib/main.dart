import 'package:earthquake_warning/accelerometer_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'app_provider.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppProvider())
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Earthquake Warning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AccelerometerData _data = AccelerometerData("0", "0", "0");
  List<double> xValues = [];
  List<double> yValues = [];
  List<double> zValues = [];
  int _start = 0;
  late AnimationController _animationController;
  bool _isEarthquakeDetected = false;

  void getSensorsData(AppProvider appProvider) {
    userAccelerometerEvents.listen(
          (UserAccelerometerEvent event) {
        setState(() {
          _data = AccelerometerData(
            event.x.toStringAsFixed(3),
            event.y.toStringAsFixed(3),
            event.z.toStringAsFixed(3),
          );
          xValues.add(event.x);
          yValues.add(event.y);
          zValues.add(event.z);
          if (xValues.length > 100) {
            xValues.removeAt(0);
            yValues.removeAt(0);
            zValues.removeAt(0);
            _start++;
          }

          // Earthquake detection logic
          double maxAcceleration = xValues.last.abs() > yValues.last.abs()
              ? xValues.last.abs()
              : yValues.last.abs();
          maxAcceleration =
          maxAcceleration > zValues.last.abs() ? maxAcceleration : zValues.last.abs();
          if (maxAcceleration > 2) {
            _isEarthquakeDetected = true;
          }
        });
      },
      onError: (error) {
        // Handle error
      },
      cancelOnError: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getSensorsData(context.read<AppProvider>());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earthquake Warning'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Accelerometer Data:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('X: ${_data.x}'),
          Text('Y: ${_data.y}'),
          Text('Z: ${_data.z}'),
          SizedBox(height: 20),
          Text(
            'Graph of Accelerometer Readings:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Container(
            height: MediaQuery.of(context).size.height / 3,
            padding: EdgeInsets.all(8),
            child: LineChart(
              LineChartData(
                minX: _start.toDouble(),
                maxX: (_start + 100).toDouble(),
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTitles: (value) {
                      if ((value.toInt() - _start) % 10 == 0) {
                        return (value.toInt() + _start).toString();
                      } else {
                        return '';
                      }
                    },
                    reservedSize: 20,
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    getTitles: (value) {
                      return value.toStringAsFixed(2);
                    },
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: xValues
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                      (e.key + _start).toDouble(),
                      e.value,
                    ))
                        .toList(),
                    colors: [Colors.red],
                    isCurved: false,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: yValues
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                      (e.key + _start).toDouble(),
                      e.value,
                    ))
                        .toList(),
                    colors: [Colors.green],
                    isCurved: false,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: zValues
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                      (e.key + _start).toDouble(),
                      e.value,
                    ))
                        .toList(),
                    colors: [Colors.blue],
                    isCurved: false,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
              swapAnimationDuration: Duration.zero,
              // animationController: _animationController,
            ),
          ),
          SizedBox(height: 20),
          if (_isEarthquakeDetected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Earthquake Detected!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text("7 devices have reported the vibration in the last 5 minutes.",style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                //   give some precautionary measures
                  Text("Precautionary Measures:",style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),),
                  Text("1. Drop down to the ground and take cover under a table or desk.",style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    // fontWeight: FontWeight.bold,
                  ),),
                  Text("2. Hold on to your shelter and be prepared to move with it until the shaking stops.",style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    // fontWeight: FontWeight.bold,
                  ),),
                  Text("3. Stay indoors until the shaking stops and you're sure it's safe to exit.",style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    // fontWeight: FontWeight.bold,
                  ),),

                ],
              ),
            ),
        ],
      ),
    );
  }
}