import 'package:flutter/material.dart';
import 'isometric_world_map.dart';

/// Non-web fallback widget: Renders native 2D isometric tycoon world.
class ThreeJsCityView extends StatelessWidget {
  const ThreeJsCityView({super.key});

  @override
  Widget build(BuildContext context) {
    return const IsometricWorldMap();
  }
}
