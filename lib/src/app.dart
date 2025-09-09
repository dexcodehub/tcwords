import 'package:flutter/material.dart';
import 'package:tcword/src/router/app_router.dart';
import 'package:tcword/src/theme/app_theme.dart';
import 'package:tcword/src/services/audio_service.dart';
import 'package:tcword/src/services/achievement_service.dart';
import 'package:tcword/src/services/ai_image_service.dart';
import 'package:tcword/src/services/static_word_image_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    // 初始化音频服务
    await AudioService.initialize();
    
    // 初始化成就服务
    await AchievementServiceSingleton.instance.initialize('guest_user');
    
    // 初始化AI图片服务
    await AIImageServiceSingleton.instance.initialize();
    
    // 初始化静态图片服务 (更快、更稳定)
    await StaticWordImageService.instance.initialize();
    
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Initializing services...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'TCWord - English Learning Adventure',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}