import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/theme_provider.dart';
import 'router.dart';

class GaleridenApp extends ConsumerWidget {
  const GaleridenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Galeriden',
      debugShowCheckedModeBanner: false,
      theme: themeState.buildThemeData(),
      routerConfig: appRouter,
    );
  }
}
