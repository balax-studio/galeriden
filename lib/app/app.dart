import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/theme_provider.dart';
import 'router.dart';

class GalerisindenApp extends ConsumerWidget {
  const GalerisindenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Galerisinden',
      debugShowCheckedModeBanner: false,
      theme: themeState.buildThemeData(),
      routerConfig: appRouter,
    );
  }
}
