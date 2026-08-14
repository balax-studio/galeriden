import 'package:flutter/material.dart';
import '../workshop/workshop_screen.dart';

class CarWashScreen extends StatelessWidget {
  const CarWashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkshopScreen(initialTabIndex: 1);
  }
}
