import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/custom_text_field.dart';
import 'package:tcword/src/widgets/custom_button.dart';
import 'package:tcword/src/widgets/difficulty_badge.dart';
import 'package:tcword/src/widgets/learning/word_card.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/models/course_model.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('搜索场景可复用组件测试', () {
    testWidgets('SearchTextField在搜索场景下的适用性测试', (WidgetTester tester) async {
      String searchQuery = '';
      bool clearCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SearchTextField(
                hintText: '搜索单词、含义或例句',
                onChanged: (value) {
                  searchQuery = value;
                },
                onClear: () {
                  clearCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // 验证SearchTextField基本渲染
      expect(find.byType(SearchTextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // 测试搜索功能
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      expect(searchQuery, equals('hello'));

      // 验证清除按钮出现
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // 测试清除功能
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(clearCalled, isTrue);
    });

    testWidgets('CustomButton作为筛选器按钮的适用性测试', (WidgetTester tester) async {
      bool allSelected = true;
      bool beginnerSelected = false;
      bool intermediateSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Wrap(
                    spacing: 8,
                    children: [
                      CustomButton(
                        text: '全部',
                        isOutlined: !allSelected,
                        onPressed: () {
                          setState(() {
                            allSelected = true;
                            beginnerSelected = false;
                            intermediateSelected = false;
                          });
                        },
                        height: 36,
                      ),
                      CustomButton(
                        text: '入门',
                        isOutlined: !beginnerSelected,
                        onPressed: () {
                          setState(() {
                            allSelected = false;
                            beginnerSelected = !beginnerSelected;
                          });
                        },
                        height: 36,
                      ),
                      CustomButton(
                        text: '中级',
                        isOutlined: !intermediateSelected,
                        onPressed: () {
                          setState(() {
                            allSelected = false;
                            intermediateSelected = !intermediateSelected;
                          });
                        },
                        height: 36,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // 验证筛选器按钮渲染
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('入门'), findsOneWidget);
      expect(find.text('中级'), findsOneWidget);

      // 测试筛选器选择逻辑
      await tester.tap(find.text('入门'));
      await tester.pump();

      // 验证按钮状态切换
      expect(find.byType(CustomButton), findsNWidgets(3));
    });

    testWidgets('DifficultyBadge在筛选器中的适用性测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 常规样式
                  DifficultyBadge(level: DifficultyLevel.beginner),
                  const SizedBox(height: 8),
                  // 紧凑样式（用于筛选器）
                  Row(
                    children: [
                      DifficultyBadge(
                        level: DifficultyLevel.beginner,
                        compact: true,
                      ),
                      const SizedBox(width: 8),
                      DifficultyBadge(
                        level: DifficultyLevel.intermediate,
                        compact: true,
                      ),
                      const SizedBox(width: 8),
                      DifficultyBadge(
                        level: DifficultyLevel.advanced,
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 验证DifficultyBadge渲染
      expect(find.byType(DifficultyBadge), findsNWidgets(4));
      expect(find.text('入门'), findsNWidgets(2));
      expect(find.text('中级'), findsOneWidget);
      expect(find.text('高级'), findsOneWidget);
    });

    testWidgets('WordCard在搜索结果中的适用性测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'search_result_1',
        text: 'beautiful',
        category: 'adjectives',
        imagePath: 'assets/images/beautiful.png',
        audioPath: 'assets/audios/beautiful.mp3',
        meaning: '美丽的',
        example: 'She is beautiful.',
        difficulty: WordDifficulty.intermediate,
        learningStatus: LearningStatus.learning,
        isBookmarked: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: WordCard(
                word: testWord,
                width: 350,
                height: 200, // 搜索结果中使用较小的高度
              ),
            ),
          ),
        ),
      );

      // 验证WordCard在搜索结果中正常显示
      expect(find.byType(WordCard), findsOneWidget);
      expect(find.text('beautiful'), findsOneWidget);
      expect(find.text('ADJECTIVES'), findsOneWidget);
    });

    testWidgets('搜索组合场景测试', (WidgetTester tester) async {
      final testWords = [
        Word(
          id: 'combo_test_1',
          text: 'apple',
          category: 'fruits',
          imagePath: 'assets/images/apple.png',
          audioPath: 'assets/audios/apple.mp3',
          meaning: '苹果',
          difficulty: WordDifficulty.beginner,
        ),
        Word(
          id: 'combo_test_2',
          text: 'sophisticated',
          category: 'adjectives',
          imagePath: 'assets/images/sophisticated.png',
          audioPath: 'assets/audios/sophisticated.mp3',
          meaning: '复杂的，精密的',
          difficulty: WordDifficulty.advanced,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 搜索框
                  SearchTextField(
                    hintText: '搜索单词',
                    onChanged: (value) {
                      // 搜索逻辑
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 筛选器
                  Builder(
                    builder: (context) => Row(
                      children: [
                        Text('难度：', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(width: 8),
                        DifficultyBadge(
                          level: DifficultyLevel.beginner,
                          compact: true,
                        ),
                        const SizedBox(width: 8),
                        DifficultyBadge(
                          level: DifficultyLevel.advanced,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 搜索结果
                  Expanded(
                    child: ListView.builder(
                      itemCount: testWords.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: WordCard(
                            word: testWords[index],
                            height: 150,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 验证完整搜索界面
      expect(find.byType(SearchTextField), findsOneWidget);
      expect(find.byType(DifficultyBadge), findsNWidgets(2));
      expect(find.byType(WordCard), findsNWidgets(2));
      expect(find.text('apple'), findsOneWidget);
      expect(find.text('sophisticated'), findsOneWidget);
    });

    testWidgets('自定义筛选按钮样式测试', (WidgetTester tester) async {
      bool categoryFilter = false;
      bool statusFilter = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      // 分类筛选
                      CustomButton(
                        text: '名词',
                        icon: Icons.category,
                        isOutlined: !categoryFilter,
                        onPressed: () {
                          setState(() {
                            categoryFilter = !categoryFilter;
                          });
                        },
                        height: 40,
                        width: 100,
                      ),
                      const SizedBox(height: 8),
                      
                      // 学习状态筛选
                      CustomButton(
                        text: '已掌握',
                        icon: Icons.check_circle,
                        isOutlined: !statusFilter,
                        backgroundColor: statusFilter ? Colors.green : null,
                        onPressed: () {
                          setState(() {
                            statusFilter = !statusFilter;
                          });
                        },
                        height: 40,
                        width: 100,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      // 验证筛选按钮样式
      expect(find.text('名词'), findsOneWidget);
      expect(find.text('已掌握'), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // 测试状态切换
      await tester.tap(find.text('名词'));
      await tester.pump();

      await tester.tap(find.text('已掌握'));
      await tester.pump();

      // 验证组件正常工作
      expect(find.byType(CustomButton), findsNWidgets(2));
    });

    testWidgets('搜索性能测试 - 组件响应速度', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                SearchTextField(
                  hintText: '性能测试搜索框',
                  onChanged: (value) {
                    // 模拟搜索处理
                  },
                ),
                ...List.generate(20, (index) => CustomButton(
                  text: '筛选器 $index',
                  isOutlined: true,
                  onPressed: () {},
                  height: 32,
                )),
              ],
            ),
          ),
        ),
      );

      stopwatch.stop();

      // 验证大量组件的渲染性能（应该小于500ms）
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      expect(find.byType(SearchTextField), findsOneWidget);
      expect(find.byType(CustomButton), findsNWidgets(20));
    });

    testWidgets('响应式布局测试', (WidgetTester tester) async {
      // 测试小屏幕布局
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                SearchTextField(hintText: '响应式测试'),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    DifficultyBadge(level: DifficultyLevel.beginner, compact: true),
                    DifficultyBadge(level: DifficultyLevel.intermediate, compact: true),
                    DifficultyBadge(level: DifficultyLevel.advanced, compact: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // 验证在小屏幕上正常显示
      expect(find.byType(SearchTextField), findsOneWidget);
      expect(find.byType(DifficultyBadge), findsNWidgets(3));

      // 重置屏幕尺寸
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
    });

    testWidgets('无障碍访问测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                SearchTextField(
                  hintText: '搜索单词',
                ),
                CustomButton(
                  text: '筛选入门级',
                  onPressed: () {},
                ),
                DifficultyBadge(level: DifficultyLevel.beginner),
              ],
            ),
          ),
        ),
      );

      // 验证关键元素存在（用于语音阅读器）
      expect(find.text('搜索单词'), findsOneWidget);
      expect(find.text('筛选入门级'), findsOneWidget);
      expect(find.text('入门'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}