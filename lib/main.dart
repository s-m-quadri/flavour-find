import 'package:flutter/material.dart';
import 'package:myapp/data/model.dart';
import 'package:myapp/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final String title = "Flavor Find";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: DataLoad(title: title),
    );
  }
}

class DataLoad extends StatefulWidget {
  const DataLoad({super.key, required this.title});
  final String title;

  @override
  State<DataLoad> createState() => _DataLoadState();
}

class _DataLoadState extends State<DataLoad> {
  final dataModel = DataModel();

  @override
  Widget build(BuildContext context) {
    return Home(
      title: widget.title,
      dataModel: dataModel,
    );
  }
}
