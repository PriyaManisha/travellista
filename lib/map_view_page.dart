import 'package:flutter/material.dart';
import 'package:travellista/shared_scaffold.dart';

class MapViewPage extends StatefulWidget {

  const MapViewPage({super.key});

  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SharedScaffold(
      title: 'Map View',
      selectedIndex: 2,
      body: Container(
        color: Colors.grey,
      ),
    );
  }
}