import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/custom_button.dart';
import 'package:tcword/src/widgets/custom_text_field.dart';
import 'package:tcword/src/widgets/learning/word_card.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  // 初始化Flutter绑定
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('收藏场景可复用组件适用性测试', () {
    late List<Word> testBookmarkedWords;

    setUp(() {
      testBookmarkedWords = [
        Word(
          id: '1',
          text: 'favorite',
          category: 'adjectives',
          imagePath: 'assets/images/favorite.png',
          audioPath: 'assets/audios/favorite.mp3',
          meaning: '最喜欢的',
          difficulty: WordDifficulty.beginner,
          learningStatus: LearningStatus.mastered,
          isBookmarked: true,
        ),
        Word(
          id: '2',
          text: 'excellent',
          category: 'adjectives',
          imagePath: 'assets/images/excellent.png',
          audioPath: 'assets/audios/excellent.mp3',
          meaning: '优秀的',
          difficulty: WordDifficulty.intermediate,
          learningStatus: LearningStatus.learning,
          isBookmarked: true,
        ),
        Word(
          id: '3',
          text: 'wonderful',
          category: 'adjectives',
          imagePath: 'assets/images/wonderful.png',
          audioPath: 'assets/audios/wonderful.mp3',
          meaning: '精彩的',
          difficulty: WordDifficulty.advanced,
          learningStatus: LearningStatus.reviewing,
          isBookmarked: true,
        ),
      ];
    });

    testWidgets('WordCard在收藏列表中的适用性测试', (WidgetTester tester) async {
      bool bookmarkToggled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ListView.builder(
              itemCount: testBookmarkedWords.length,
              itemBuilder: (context, index) {
                final word = testBookmarkedWords[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: WordCard(
                    word: word,
                    isInteractive: true,
                    width: double.infinity,
                    height: 120, // 紧凑模式
                    onBookmarkToggle: () => bookmarkToggled = true,
                  ),
                );
              },
            ),
          ),
        ),
      );

      // 验证收藏单词正常显示
      expect(find.text('favorite'), findsOneWidget);
      expect(find.text('excellent'), findsOneWidget);
      expect(find.text('wonderful'), findsOneWidget);

      // 验证收藏图标显示
      expect(find.byIcon(Icons.bookmark), findsAtLeastNWidgets(3));

      // 测试收藏切换功能
      await tester.tap(find.byIcon(Icons.bookmark).first);
      await tester.pump();
      expect(bookmarkToggled, isTrue);
    });

    testWidgets('CustomButton在筛选操作中的适用性测试', (WidgetTester tester) async {
      String selectedFilter = '';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                // 筛选按钮组
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: '全部',
                        onPressed: () => selectedFilter = 'all',
                        isOutlined: selectedFilter != 'all',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        text: '已掌握',
                        onPressed: () => selectedFilter = 'mastered',
                        isOutlined: selectedFilter != 'mastered',
                        backgroundColor: selectedFilter == 'mastered' 
                            ? Colors.green 
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        text: '学习中',
                        onPressed: () => selectedFilter = 'learning',
                        isOutlined: selectedFilter != 'learning',
                        backgroundColor: selectedFilter == 'learning' 
                            ? Colors.blue 
                            : null,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: '批量取消收藏',
                        icon: Icons.bookmark_remove,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryButton(
                        text: '开始复习',
                        icon: Icons.play_arrow,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // 验证筛选按钮
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('已掌握'), findsOneWidget);
      expect(find.text('学习中'), findsOneWidget);

      // 验证操作按钮
      expect(find.text('批量取消收藏'), findsOneWidget);
      expect(find.text('开始复习'), findsOneWidget);

      // 测试筛选功能
      await tester.tap(find.text('已掌握'));
      expect(selectedFilter, equals('mastered'));
    });

    testWidgets('CustomTextField在搜索功能中的适用性测试', (WidgetTester tester) async {
      String searchQuery = '';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                // 搜索框
                CustomTextField(
                  hintText: '搜索收藏的单词...',
                  prefixIcon: Icons.search,
                  onChanged: (value) => searchQuery = value,
                ),
                
                const SizedBox(height: 16),
                
                // 搜索结果提示
                Text('搜索结果: $searchQuery'),
              ],
            ),
          ),
        ),
      );

      // 验证搜索框显示
      expect(find.text('搜索收藏的单词...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // 测试搜索功能
      await tester.enterText(find.byType(CustomTextField), 'favorite');
      expect(searchQuery, equals('favorite'));
    });

    testWidgets('收藏列表不同视图模式测试', (WidgetTester tester) async {
      bool isGridView = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('我的收藏'),
                  actions: [
                    IconButton(
                      icon: Icon(isGridView ? Icons.list : Icons.grid_view),
                      onPressed: () {
                        setState(() {
                          isGridView = !isGridView;
                        });
                      },
                    ),
                  ],
                ),
                body: isGridView
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: testBookmarkedWords.length,
                        itemBuilder: (context, index) {
                          return WordCard(
                            word: testBookmarkedWords[index],
                            width: 150,
                            height: 120,
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: testBookmarkedWords.length,
                        itemBuilder: (context, index) {
                          return WordCard(
                            word: testBookmarkedWords[index],
                            width: double.infinity,
                            height: 100,
                          );
                        },
                      ),
              );
            },
          ),
        ),
      );

      // 验证初始列表视图
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.text('favorite'), findsOneWidget);

      // 切换到网格视图
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();

      // 验证网格视图
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.text('favorite'), findsOneWidget);
    });

    testWidgets('收藏统计信息显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                // 统计卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '收藏统计',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('总计', '${testBookmarkedWords.length}', Colors.blue),
                            _buildStatItem('已掌握', '1', Colors.green),
                            _buildStatItem('学习中', '1', Colors.orange),
                            _buildStatItem('复习中', '1', Colors.purple),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 验证统计信息显示
      expect(find.text('收藏统计'), findsOneWidget);
      expect(find.text('总计'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('已掌握'), findsOneWidget);
      expect(find.text('学习中'), findsOneWidget);
      expect(find.text('复习中'), findsOneWidget);
    });

    testWidgets('空收藏状态显示测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有收藏任何单词',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击单词卡片上的收藏按钮来收藏喜欢的单词',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: '去学习单词',
                    icon: Icons.school,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 验证空状态显示
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.text('还没有收藏任何单词'), findsOneWidget);
      expect(find.text('去学习单词'), findsOneWidget);
    });

    testWidgets('收藏长按批量操作测试', (WidgetTester tester) async {
      bool longPressTriggered = false;
      bool isSelectionMode = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(isSelectionMode ? '选择项目' : '我的收藏'),
                  actions: isSelectionMode
                      ? [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelectionMode = false;
                              });
                            },
                            child: const Text('取消'),
                          ),
                        ]
                      : null,
                ),
                body: ListView.builder(
                  itemCount: testBookmarkedWords.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () {
                        longPressTriggered = true;
                        setState(() {
                          isSelectionMode = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelectionMode 
                              ? Colors.blue.withOpacity(0.1) 
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (isSelectionMode)
                              Checkbox(
                                value: false,
                                onChanged: (value) {},
                              ),
                            Expanded(
                              child: WordCard(
                                word: testBookmarkedWords[index],
                                width: double.infinity,
                                height: 80,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                bottomNavigationBar: isSelectionMode
                    ? BottomAppBar(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButton(
                              text: '取消收藏',
                              icon: Icons.bookmark_remove,
                              onPressed: () {},
                              backgroundColor: Colors.red,
                            ),
                            CustomButton(
                              text: '开始复习',
                              icon: Icons.play_arrow,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      );

      // 验证初始状态
      expect(find.text('我的收藏'), findsOneWidget);

      // 测试长按操作
      await tester.longPress(find.text('favorite'));
      await tester.pumpAndSettle();

      expect(longPressTriggered, isTrue);
      expect(find.text('选择项目'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.byType(Checkbox), findsAtLeastNWidgets(1));
      expect(find.text('取消收藏'), findsOneWidget);
    });

    testWidgets('收藏分类筛选测试', (WidgetTester tester) async {
      String selectedCategory = '';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                // 分类筛选
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('全部'),
                        selected: selectedCategory == '',
                        onSelected: (selected) => selectedCategory = '',
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('形容词'),
                        selected: selectedCategory == 'adjectives',
                        onSelected: (selected) => selectedCategory = 'adjectives',
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('名词'),
                        selected: selectedCategory == 'nouns',
                        onSelected: (selected) => selectedCategory = 'nouns',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 验证分类筛选
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('形容词'), findsOneWidget);
      expect(find.text('名词'), findsOneWidget);

      // 测试筛选功能
      await tester.tap(find.text('形容词'));
      expect(selectedCategory, equals('adjectives'));
    });
  });
}

Widget _buildStatItem(String label, String value, Color color) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    ],
  );
}