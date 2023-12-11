import 'package:flutter/material.dart';
import 'package:footy_fix/services/geolocator_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    GeolocatorService().determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        // bottomNavigationBar: NavBar(),
        );
  }
}
