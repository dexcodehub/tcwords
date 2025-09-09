import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcword/src/widgets/custom_button.dart';
import 'package:tcword/src/widgets/progress_indicator.dart';
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

  group('测验场景可复用组件适用性测试', () {
    testWidgets('CustomButton在答案选项中的适用性测试', (WidgetTester tester) async {
      bool option1Selected = false;
      bool option2Selected = false;
      bool option3Selected = false;
      bool option4Selected = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                Text('选择正确答案：'),
                SizedBox(height: 20),
                
                // 模拟测验选项按钮
                CustomButton(
                  text: 'A. 汽车',
                  onPressed: () => option1Selected = true,
                  isOutlined: true,
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                
                CustomButton(
                  text: 'B. 卡车',
                  onPressed: () => option2Selected = true,
                  isOutlined: true,
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                
                CustomButton(
                  text: 'C. 公交车',
                  onPressed: () => option3Selected = true,
                  backgroundColor: Colors.green, // 正确答案高亮
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                
                CustomButton(
                  text: 'D. 自行车',
                  onPressed: () => option4Selected = true,
                  backgroundColor: Colors.red, // 错误答案高亮
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      );

      // 验证选项按钮正常显示
      expect(find.text('A. 汽车'), findsOneWidget);
      expect(find.text('B. 卡车'), findsOneWidget);
      expect(find.text('C. 公交车'), findsOneWidget);
      expect(find.text('D. 自行车'), findsOneWidget);

      // 测试选项点击
      await tester.tap(find.text('A. 汽车'));
      expect(option1Selected, isTrue);

      await tester.tap(find.text('C. 公交车'));
      expect(option3Selected, isTrue);
    });

    testWidgets('CustomProgressIndicator在测验进度中的适用性测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                Text('测验进度'),
                SizedBox(height: 20),
                
                // 线性进度条 - 总体进度
                CustomProgressIndicator(
                  progress: 0.4, // 40% 完成
                  height: 10,
                  showPercentage: true,
                ),
                SizedBox(height: 20),
                
                // 分段进度条 - 题目进度
                SegmentedProgressIndicator(
                  totalSegments: 10,
                  completedSegments: 4,
                  segmentWidth: 25,
                  segmentHeight: 6,
                ),
                SizedBox(height: 20),
                
                // 圆形进度条 - 当前题目倒计时
                CustomCircularProgressIndicator(
                  progress: 0.75, // 75% 时间剩余
                  size: 80,
                  showPercentage: true,
                ),
              ],
            ),
          ),
        ),
      );

      // 验证进度指示器正常显示
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(CustomProgressIndicator), findsOneWidget);
      expect(find.byType(SegmentedProgressIndicator), findsOneWidget);
      expect(find.byType(CustomCircularProgressIndicator), findsOneWidget);
    });

    testWidgets('WordCard在测验题目显示中的适用性测试', (WidgetTester tester) async {
      final testWord = Word(
        id: 'quiz_test',
        text: 'car',
        category: 'vehicles',
        imagePath: 'assets/images/car.png',
        audioPath: 'assets/audios/car.mp3',
        meaning: '汽车',
        difficulty: WordDifficulty.beginner,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                Text('听音选义'),
                SizedBox(height: 20),
                
                // 使用WordCard作为题目显示（只读模式）
                WordCard(
                  word: testWord,
                  isInteractive: false, // 测验中为只读
                  showAnswer: false, // 不显示答案
                  width: 300,
                  height: 200,
                ),
              ],
            ),
          ),
        ),
      );

      // 验证WordCard正常显示
      expect(find.text('car'), findsOneWidget);
      expect(find.text('VEHICLES'), findsOneWidget);
      
      // 验证发音按钮存在（用于听音题型）
      expect(find.text('发音'), findsOneWidget);
      
      // 在只读模式下，收藏按钮应该不显示
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
    });

    testWidgets('组合场景测试 - 完整测验界面模拟', (WidgetTester tester) async {
      final testWord = Word(
        id: 'quiz_combined_test',
        text: 'beautiful',
        category: 'adjectives',
        imagePath: 'assets/images/beautiful.png',
        audioPath: 'assets/audios/beautiful.mp3',
        meaning: '美丽的',
        difficulty: WordDifficulty.intermediate,
      );

      int selectedOption = -1;
      bool nextPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              title: Text('词汇测验'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 进度显示
                  Row(
                    children: [
                      Text('题目 4/10'),
                      Spacer(),
                      CustomCircularProgressIndicator(
                        progress: 0.8,
                        size: 40,
                        showPercentage: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  
                  SegmentedProgressIndicator(
                    totalSegments: 10,
                    completedSegments: 3,
                    segmentWidth: 30,
                  ),
                  SizedBox(height: 30),
                  
                  // 题目
                  Text(
                    '选择下面单词的正确含义：',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  
                  // 单词卡片
                  Center(
                    child: WordCard(
                      word: testWord,
                      isInteractive: false,
                      width: 250,
                      height: 150,
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // 选项
                  Text('选择答案:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 15),
                  
                  ...List.generate(4, (index) {
                    final options = ['美丽的', '困难的', '简单的', '古老的'];
                    final isSelected = selectedOption == index;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: CustomButton(
                        text: '${String.fromCharCode(65 + index)}. ${options[index]}',
                        onPressed: () => selectedOption = index,
                        isOutlined: !isSelected,
                        backgroundColor: isSelected 
                            ? Colors.blue 
                            : null,
                        width: double.infinity,
                      ),
                    );
                  }),
                  
                  SizedBox(height: 30),
                  
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: '跳过',
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: PrimaryButton(
                          text: '下一题',
                          onPressed: selectedOption >= 0 
                              ? () => nextPressed = true 
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 验证整体界面渲染
      expect(find.text('词汇测验'), findsOneWidget);
      expect(find.text('题目 4/10'), findsOneWidget);
      expect(find.text('beautiful'), findsOneWidget);
      expect(find.text('选择下面单词的正确含义：'), findsOneWidget);
      
      // 验证选项按钮
      expect(find.text('A. 美丽的'), findsOneWidget);
      expect(find.text('B. 困难的'), findsOneWidget);
      expect(find.text('C. 简单的'), findsOneWidget);
      expect(find.text('D. 古老的'), findsOneWidget);
      
      // 验证操作按钮
      expect(find.text('跳过'), findsOneWidget);
      expect(find.text('下一题'), findsOneWidget);
      
      // 测试选择答案
      await tester.tap(find.text('A. 美丽的'));
      await tester.pump();
      
      // 测试提交答案
      await tester.tap(find.text('下一题'));
      expect(nextPressed, isTrue);
    });

    testWidgets('动画进度指示器在测验中的适用性测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                Text('测验进度动画'),
                SizedBox(height: 20),
                
                // 动画进度条 - 模拟答题后进度更新
                AnimatedProgressIndicator(
                  progress: 0.5,
                  duration: Duration(milliseconds: 500),
                  showPercentage: true,
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      );

      // 验证动画进度条正常显示
      expect(find.byType(AnimatedProgressIndicator), findsOneWidget);
      
      // 等待动画完成
      await tester.pumpAndSettle();
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('CustomButton不同状态在测验反馈中的适用性', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                Text('答案反馈'),
                SizedBox(height: 20),
                
                // 正确答案按钮
                CustomButton(
                  text: '✓ 正确答案',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  width: double.infinity,
                  onPressed: null, // 禁用状态
                ),
                SizedBox(height: 10),
                
                // 错误答案按钮
                CustomButton(
                  text: '✗ 错误答案',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  width: double.infinity,
                  onPressed: null, // 禁用状态
                ),
                SizedBox(height: 10),
                
                // 用户选择的错误答案
                CustomButton(
                  text: '你的选择（错误）',
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                  width: double.infinity,
                  onPressed: null,
                ),
                SizedBox(height: 20),
                
                // 继续按钮
                PrimaryButton(
                  text: '继续',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // 验证反馈状态显示
      expect(find.text('✓ 正确答案'), findsOneWidget);
      expect(find.text('✗ 错误答案'), findsOneWidget);
      expect(find.text('你的选择（错误）'), findsOneWidget);
      expect(find.text('继续'), findsOneWidget);
    });

    testWidgets('测验结果界面组件适用性测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              title: Text('测验结果'),
            ),
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // 总体分数圆形进度
                  CustomCircularProgressIndicator(
                    progress: 0.85, // 85分
                    size: 120,
                    strokeWidth: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('85', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('分', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // 详细统计
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('正确率'),
                              Spacer(),
                              CustomProgressIndicator(
                                progress: 0.8,
                                showPercentage: true,
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text('完成率'),
                              Spacer(),
                              CustomProgressIndicator(
                                progress: 1.0,
                                showPercentage: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: '查看错题',
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: PrimaryButton(
                          text: '再次挑战',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 验证结果界面组件
      expect(find.text('测验结果'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('分'), findsOneWidget);
      expect(find.text('正确率'), findsOneWidget);
      expect(find.text('完成率'), findsOneWidget);
      expect(find.text('查看错题'), findsOneWidget);
      expect(find.text('再次挑战'), findsOneWidget);
    });
  });
}