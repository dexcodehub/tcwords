import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../models/user_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final StorageService _storageService = StorageService();
  User? _currentUser;
  bool _isGuestMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _storageService.getCurrentUser();
      final isGuest = await _storageService.isGuestMode();
      if (mounted) {
        setState(() {
          _currentUser = user;
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

    return ChangeNotifierProvider(
      create: (context) => AuthViewModel(
        AuthService(),
        StorageService(),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Stats Section
                _buildStatsSection(),
                
                const SizedBox(height: 32),
                
                // Quick Actions
                _buildQuickActions(),
                
                const SizedBox(height: 32),
                
                // Recent Progress
                _buildRecentProgress(),
                
                const SizedBox(height: 32),
                
                // Featured Courses
                _buildFeaturedCourses(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final userName = _isGuestMode ? 'Guest' : (_currentUser?.displayName ?? 'Student');
    final welcomeText = _isGuestMode ? 'Welcome,' : 'Welcome back,';
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                welcomeText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
        
        // Profile Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.person,
            color: theme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '7',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  label: 'XP',
                  value: '1,250',
                  color: Colors.purple,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.diamond,
                  label: 'Gems',
                  value: '45',
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.play_circle_fill,
                title: 'Continue Learning',
                subtitle: 'Resume your lesson',
                color: theme.colorScheme.primary,
                onTap: () {
                  // Navigate to word learning
                  context.push('/word-learning');
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildActionCard(
                icon: Icons.quiz,
                title: 'Daily Challenge',
                subtitle: 'Test your skills',
                color: Colors.orange,
                onTap: () {
                  // Navigate to games section
                  context.push('/games');
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.emoji_events,
                title: 'Achievements',
                subtitle: 'View your progress',
                color: Colors.amber,
                onTap: () {
                  context.push('/achievements');
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildActionCard(
                icon: Icons.leaderboard,
                title: 'Leaderboard',
                subtitle: 'Compare scores',
                color: Colors.green,
                onTap: () {
                  context.push('/leaderboard');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProgress() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Progress',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.book,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Vocabulary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Lesson 3 of 10 completed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    LinearProgressIndicator(
                      value: 0.3,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCourses() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Courses',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              final courses = [
                {
                  'title': 'English Basics',
                  'subtitle': 'Perfect for beginners',
                  'color': Colors.blue,
                  'icon': Icons.abc,
                },
                {
                  'title': 'Conversation Skills',
                  'subtitle': 'Practice speaking',
                  'color': Colors.green,
                  'icon': Icons.chat,
                },
                {
                  'title': 'Grammar Master',
                  'subtitle': 'Advanced grammar',
                  'color': Colors.purple,
                  'icon': Icons.school,
                },
              ];
              
              final course = courses[index];
              
              return Container(
                width: 160,
                margin: EdgeInsets.only(
                  right: index < courses.length - 1 ? 16 : 0,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (course['color'] as Color).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (course['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        course['icon'] as IconData,
                        color: course['color'] as Color,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      course['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      course['subtitle'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/courses');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: course['color'] as Color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}