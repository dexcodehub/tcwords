import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/home_view.dart';
import '../views/courses_view.dart';
import '../views/course_detail_view.dart';
import '../views/word_learning_view.dart';
import '../views/progress_view.dart';
import '../views/game_view.dart';
import '../views/achievements_view.dart';
import '../views/parental_control_view.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // Authentication Routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterView(),
    ),
    
    // Main App Routes
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeView(),
    ),
    
    // Courses
    GoRoute(
      path: '/courses',
      name: 'courses',
      builder: (context, state) => const CoursesView(),
    ),
    
    // Games
    GoRoute(
      path: '/games',
      name: 'games',
      builder: (context, state) => const GameView(),
    ),
    
    // Progress
    GoRoute(
      path: '/progress',
      name: 'progress',
      builder: (context, state) => const ProgressView(),
    ),
    
    // Achievements
    GoRoute(
      path: '/achievements',
      name: 'achievements',
      builder: (context, state) => const AchievementsView(),
    ),
    
    // Word Learning
    GoRoute(
      path: '/word-learning',
      name: 'word-learning',
      builder: (context, state) => const WordLearningView(),
    ),
    
    // Parental Control
    GoRoute(
      path: '/parental-control',
      name: 'parental-control',
      builder: (context, state) => const ParentalControlView(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page Not Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The page you are looking for does not exist.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);