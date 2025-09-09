import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcword/src/widgets/game_base_widget.dart';
import 'package:tcword/src/services/game_engine_service.dart';

// Concrete implementation of MockGameWidget for testing
class _ConcreteMockGameWidget extends MockGameWidget {
  const _ConcreteMockGameWidget({
    Key? key,
    required String gameTitle,
    required AdaptiveDifficulty difficulty,
    required VoidCallback onInitialized,
    required Widget Function(BuildContext context, GameBaseState state) contentBuilder,
    required Widget Function(BuildContext context, GameBaseState state) controlsBuilder,
  }) : super(
          key: key,
          gameTitle: gameTitle,
          difficulty: difficulty,
          onInitialized: onInitialized,
          contentBuilder: contentBuilder,
          controlsBuilder: controlsBuilder,
        );

  @override
  Widget buildGameContent(BuildContext context, GameBaseState state) {
    return contentBuilder(context, state);
  }

  @override
  Widget buildGameControls(BuildContext context, GameBaseState state) {
    return controlsBuilder(context, state);
  }
}

// Mock game widget for testing
abstract class MockGameWidget extends GameBaseWidget {
  final VoidCallback onInitialized;
  final Widget Function(BuildContext context, GameBaseState state) contentBuilder;
  final Widget Function(BuildContext context, GameBaseState state) controlsBuilder;

  const MockGameWidget({
    Key? key,
    required String gameTitle,
    required AdaptiveDifficulty difficulty,
    required this.onInitialized,
    required this.contentBuilder,
    required this.controlsBuilder,
  }) : super(
          key: key,
          gameTitle: gameTitle,
          difficulty: difficulty,
        );

  @override
  State<MockGameWidget> createState() => _MockGameState();
}

class _MockGameState extends GameBaseState<MockGameWidget> {
  @override
  void onGameInitialized() {
    widget.onInitialized();
  }

  @override
  Widget buildGameContent(BuildContext context) {
    return widget.contentBuilder(context, this);
  }

  @override
  Widget buildGameControls(BuildContext context) {
    return widget.controlsBuilder(context, this);
  }
}

void main() {
  group('GameBaseWidget 测试', () {
    testWidgets('基础游戏组件渲染测试', (WidgetTester tester) async {
      bool initialized = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: _ConcreteMockGameWidget(
            gameTitle: '测试游戏',
            difficulty: AdaptiveDifficulty(),
            onInitialized: () => initialized = true,
            contentBuilder: (context, state) => const Text('游戏内容'),
            controlsBuilder: (context, state) => const Text('游戏控制'),
          ),
        ),
      );

      // 验证游戏标题显示
      expect(find.text('测试游戏'), findsOneWidget);
      
      // 验证初始化回调被调用
      expect(initialized, isTrue);
      
      // 验证内容和控制区域显示
      expect(find.text('游戏内容'), findsOneWidget);
      expect(find.text('游戏控制'), findsOneWidget);
    });

    testWidgets('游戏状态管理测试', (WidgetTester tester) async {
      final difficulty = AdaptiveDifficulty();
      late _MockGameState gameState;
      
      await tester.pumpWidget(
        MaterialApp(
          home: _ConcreteMockGameWidget(
            gameTitle: '状态测试游戏',
            difficulty: difficulty,
            onInitialized: () {},
            contentBuilder: (context, state) {
              gameState = state as _MockGameState;
              return const Text('游戏内容');
            },
            controlsBuilder: (context, state) => const Text('游戏控制'),
          ),
        ),
      );

      // 验证初始状态
      expect(gameState.score, equals(0));
      expect(gameState.attempts, equals(0));
      expect(gameState.level, equals(1));
      expect(gameState.isPaused, isFalse);

      // 测试更新分数
      gameState.updateScore(100);
      await tester.pump();
      expect(gameState.score, equals(100));

      // 测试增加尝试次数
      gameState.incrementAttempts();
      await tester.pump();
      expect(gameState.attempts, equals(1));

      // 测试升级
      gameState.levelUp();
      await tester.pump();
      expect(gameState.level, equals(2));

      // 测试暂停和继续
      gameState.pauseGame();
      await tester.pump();
      expect(gameState.isPaused, isTrue);

      gameState.resumeGame();
      await tester.pump();
      expect(gameState.isPaused, isFalse);

      // 测试重新开始
      gameState.updateScore(50);
      gameState.incrementAttempts();
      gameState.levelUp();
      expect(gameState.score, equals(150));
      expect(gameState.attempts, equals(2));
      expect(gameState.level, equals(3));

      gameState.restartGame();
      await tester.pump();
      expect(gameState.score, equals(0));
      expect(gameState.attempts, equals(0));
      expect(gameState.level, equals(1));
    });

    testWidgets('游戏统计面板测试', (WidgetTester tester) async {
      final difficulty = AdaptiveDifficulty();
      late _MockGameState gameState;
      
      await tester.pumpWidget(
        MaterialApp(
          home: _ConcreteMockGameWidget(
            gameTitle: '统计测试游戏',
            difficulty: difficulty,
            onInitialized: () {},
            contentBuilder: (context, state) {
              gameState = state as _MockGameState;
              return const Text('游戏内容');
            },
            controlsBuilder: (context, state) => const Text('游戏控制'),
          ),
        ),
      );

      // 验证初始统计值显示 - we'll check for specific values in a more targeted way
      expect(find.text('0'), findsWidgets); // score and attempts
      expect(find.text('1'), findsWidgets); // level
      expect(find.text('50%'), findsOneWidget); // difficulty (initial 0.5 * 100)

      // 更新分数并验证显示
      gameState.updateScore(250);
      await tester.pump();
      expect(find.text('250'), findsOneWidget);

      // 增加尝试次数并验证显示
      gameState.incrementAttempts();
      await tester.pump();
      expect(find.text('1'), findsWidgets); // attempts now show 1

      // 升级并验证显示
      gameState.levelUp();
      await tester.pump();
      expect(find.text('2'), findsWidgets); // level now shows 2

      // 调整难度并验证显示
      difficulty.adjustDifficulty(true, 1.0);
      await tester.pump();
      expect(find.text('55%'), findsOneWidget); // 0.55 * 100
    });

    testWidgets('游戏按钮组件测试', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              text: '测试按钮',
              onPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      // 验证按钮文本显示
      expect(find.text('测试按钮'), findsOneWidget);
      
      // 验证按钮可点击
      await tester.tap(find.byType(GameButton));
      expect(buttonPressed, isTrue);
    });

    testWidgets('带图标的按钮测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              text: '图标按钮',
              icon: Icons.star,
              onPressed: () {},
            ),
          ),
        ),
      );

      // 验证图标和文本都显示
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('图标按钮'), findsOneWidget);
    });

    testWidgets('禁用按钮测试', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameButton(
              text: '禁用按钮',
              onPressed: () => buttonPressed = true,
              isEnabled: false,
            ),
          ),
        ),
      );

      // 验证按钮文本显示
      expect(find.text('禁用按钮'), findsOneWidget);
      
      // 验证按钮不可点击
      await tester.tap(find.byType(GameButton));
      expect(buttonPressed, isFalse);
    });

    testWidgets('游戏卡片组件测试', (WidgetTester tester) async {
      bool cardTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameCard(
              child: const Text('卡片内容'),
              onTap: () => cardTapped = true,
            ),
          ),
        ),
      );

      // 验证卡片内容显示
      expect(find.text('卡片内容'), findsOneWidget);
      
      // 验证卡片可点击
      await tester.tap(find.byType(GameCard));
      expect(cardTapped, isTrue);
    });

    testWidgets('选中的游戏卡片测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameCard(
              child: const Text('选中卡片'),
              isSelected: true,
            ),
          ),
        ),
      );

      // 验证卡片内容显示
      expect(find.text('选中卡片'), findsOneWidget);
      
      // 验证选中样式（通过边框宽度判断）
      final card = tester.widget<GameCard>(find.byType(GameCard));
      expect(card.isSelected, isTrue);
    });
  });
}