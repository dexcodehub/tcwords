import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/splash/splash_screen.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/home_view.dart';
import '../views/courses_view.dart';
import '../views/course_detail_view.dart';
import '../views/word_learning_view.dart';
import '../views/progress_view.dart';
import '../views/game_view.dart';
import '../views/achievements_view.dart';
// ProfileView is defined at the bottom of this file
import '../services/storage_service.dart';

class AppRouter {
  static final StorageService _storageService = StorageService();
  
  static final GoRouter router = GoRouter(
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
      
      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileView(),
      ),
      
      // Course Routes
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) => const CoursesView(),
      ),
      
      GoRoute(
        path: '/course/:courseId',
        name: 'course-detail',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          // TODO: Load course by ID and pass to CourseDetailView
          // For now, create a placeholder course
          return const Scaffold(
            body: Center(
              child: Text('课程详情页面开发中...'),
            ),
          );
        },
      ),
      
      // Word Learning Routes
      GoRoute(
        path: '/word-learning',
        name: 'word-learning',
        builder: (context, state) => const WordLearningView(),
      ),
      
      // Progress Routes
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressView(),
      ),
      
      // Games Routes
      GoRoute(
        path: '/games',
        name: 'games',
        builder: (context, state) => const GameView(),
      ),
      
      // Learning Routes
      GoRoute(
        path: '/lesson/:lessonId',
        name: 'lesson',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return LessonView(lessonId: lessonId);
        },
      ),
      
      // Practice Routes
      GoRoute(
        path: '/practice',
        name: 'practice',
        builder: (context, state) => const PracticeView(),
      ),
      
      // Leaderboard Routes
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardView(),
      ),
      
      // Achievements Routes
      GoRoute(
        path: '/achievements',
        name: 'achievements',
        builder: (context, state) => const AchievementsView(),
      ),
      
      // Settings Routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsView(),
      ),
    ],
    
    // Redirect logic for authentication
    redirect: (context, state) async {
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnAuth = state.matchedLocation == '/login' || 
                      state.matchedLocation == '/register';
      
      // Allow splash screen to handle initial routing
      if (isOnSplash) {
        return null;
      }
      
      // Check if user is authenticated or in guest mode
      final user = await _storageService.getCurrentUser();
      final isGuestMode = await _storageService.isGuestMode();
      final isAuthenticated = user != null;
      final isLoggedIn = isAuthenticated || isGuestMode;
      
      // If not authenticated and not on auth pages, redirect to login
      if (!isLoggedIn && !isOnAuth) {
        return '/login';
      }
      
      // If authenticated and on auth pages, redirect to home
      if (isLoggedIn && isOnAuth) {
        return '/home';
      }
      
      // No redirect needed
      return null;
    },
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Placeholder views for routes that haven't been implemented yet
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final StorageService _storageService = StorageService();
  bool _isGuestMode = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _checkGuestMode();
  }
  
  Future<void> _checkGuestMode() async {
    try {
      final isGuest = await _storageService.isGuestMode();
      if (mounted) {
        setState(() {
          _isGuestMode = isGuest;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isGuestMode ? _buildGuestView() : _buildUserView(),
    );
  }
  
  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Guest Mode',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You are currently using the app as a guest. Create an account to save your progress and unlock all features!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.go('/register');
              },
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserView() {
    return const Center(
      child: Text(
        'User Profile View\nComing Soon!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class CoursesView extends StatelessWidget {
  const CoursesView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: const Center(
        child: Text(
          'Courses View\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class CourseDetailView extends StatelessWidget {
  final String courseId;
  
  const CourseDetailView({super.key, required this.courseId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course $courseId'),
      ),
      body: Center(
        child: Text(
          'Course Detail View\nCourse ID: $courseId\nComing Soon!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class LessonView extends StatelessWidget {
  final String lessonId;
  
  const LessonView({super.key, required this.lessonId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson $lessonId'),
      ),
      body: Center(
        child: Text(
          'Lesson View\nLesson ID: $lessonId\nComing Soon!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class PracticeView extends StatelessWidget {
  const PracticeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
      ),
      body: const Center(
        child: Text(
          'Practice View\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: const Center(
        child: Text(
          'Leaderboard View\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text(
          'Settings View\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}