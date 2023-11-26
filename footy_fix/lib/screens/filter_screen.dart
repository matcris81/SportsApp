import 'package:flutter/material.dart';
import 'package:footy_fix/components/navigation.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Filter Screen'));
  }
}
