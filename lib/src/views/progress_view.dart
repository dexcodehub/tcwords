import 'package:flutter/material.dart';
import 'package:tcword/src/services/progress_service.dart';
import 'package:tcword/src/models/user_progress.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  late Future<UserProgress> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = ProgressService.getProgress();
  }

  // 刷新进度数据
  void _refreshProgress() {
    setState(() {
      _progressFuture = ProgressService.getProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProgress,
          ),
        ],
      ),
      body: FutureBuilder<UserProgress>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshProgress,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final UserProgress progress = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 总积分
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Points',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${progress.totalPoints}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (progress.totalPoints / 1000).clamp(0.0, 1.0).toDouble(),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Progress to next level',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 已完成的单词
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Completed Words',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('${progress.completedWords.length} words learned'),
                            const SizedBox(height: 12),
                            // 显示最近学习的单词（如果有）
                            if (progress.completedWords.isNotEmpty) ...[
                              const Text(
                                'Recently learned:',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: progress.completedWords.reversed.take(5).map((wordId) {
                                  return Chip(
                                    label: Text(wordId),
                                    backgroundColor: Colors.green[100],
                                  );
                                }).toList(),
                              ),
                            ] else ...[
                              const Text(
                                'Start learning words to see your progress here!',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 已完成的游戏
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Completed Games',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('${progress.completedGames.length} games completed'),
                            const SizedBox(height: 12),
                            // 显示游戏完成情况
                            if (progress.completedGames.isNotEmpty) ...[
                              const Text(
                                'Games played:',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...progress.completedGames.reversed.take(3).map((gameId) {
                                return ListTile(
                                  leading: const Icon(Icons.check_circle, color: Colors.green),
                                  title: Text(gameId),
                                  contentPadding: EdgeInsets.zero,
                                );
                              }).toList(),
                            ] else ...[
                              const Text(
                                'Play games to earn points and track your progress!',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 已解锁的奖励
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Unlocked Rewards',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('${progress.unlockedRewards.length} rewards unlocked'),
                            const SizedBox(height: 12),
                            // 显示奖励
                            if (progress.unlockedRewards.isNotEmpty) ...[
                              const Text(
                                'Your rewards:',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: progress.unlockedRewards.map((rewardId) {
                                  return Chip(
                                    label: Text(rewardId),
                                    backgroundColor: Colors.purple[100],
                                  );
                                }).toList(),
                              ),
                            ] else ...[
                              const Text(
                                'Complete activities to unlock rewards!',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 激励信息
                    Card(
                      elevation: 4,
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.emoji_events, size: 40, color: Colors.blue),
                            const SizedBox(height: 10),
                            const Text(
                              'Keep up the great work!',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getMotivationalMessage(progress),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  String _getMotivationalMessage(UserProgress progress) {
    final totalActivities = progress.completedWords.length + progress.completedGames.length;
    
    if (totalActivities == 0) {
      return 'Start learning to earn your first points!';
    } else if (totalActivities < 5) {
      return 'You\'re doing great! Keep learning!';
    } else if (totalActivities < 10) {
      return 'Amazing progress! You\'re becoming an English expert!';
    } else {
      return 'Wow! You\'re an English superstar!';
    }
  }
}