import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcword/src/widgets/custom_button.dart';
import 'package:tcword/src/widgets/custom_text_field.dart';
import 'package:tcword/src/theme/app_theme.dart';

void main() {
  group('CustomButton 组件测试', () {
    testWidgets('基础按钮渲染测试', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomButton(
              text: '测试按钮',
              onPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      // 验证按钮文本显示
      expect(find.text('测试按钮'), findsOneWidget);
      
      // 验证按钮可点击
      await tester.tap(find.byType(CustomButton));
      expect(buttonPressed, isTrue);
    });

    testWidgets('加载状态按钮测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomButton(
              text: '加载中',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // 验证加载指示器显示
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // 验证按钮文本被隐藏
      expect(find.text('加载中'), findsNothing);
    });

    testWidgets('轮廓按钮测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomButton(
              text: '轮廓按钮',
              isOutlined: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // 验证OutlinedButton被使用
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('轮廓按钮'), findsOneWidget);
    });

    testWidgets('带图标按钮测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomButton(
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

    testWidgets('按钮变体测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                PrimaryButton(text: '主要按钮', onPressed: () {}),
                SecondaryButton(text: '次要按钮', onPressed: () {}),
                DangerButton(text: '危险按钮', onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      // 验证所有按钮变体都正确渲染
      expect(find.text('主要按钮'), findsOneWidget);
      expect(find.text('次要按钮'), findsOneWidget);
      expect(find.text('危险按钮'), findsOneWidget);
    });
  });

  group('CustomTextField 组件测试', () {
    testWidgets('基础文本输入框测试', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: '测试标签',
              hintText: '请输入内容',
            ),
          ),
        ),
      );

      // 验证标签和提示文本显示
      expect(find.text('测试标签'), findsOneWidget);
      expect(find.text('请输入内容'), findsOneWidget);
      
      // 测试文本输入
      await tester.enterText(find.byType(TextFormField), '测试内容');
      expect(controller.text, equals('测试内容'));
    });

    testWidgets('带前缀图标的文本框测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomTextField(
              label: '带图标输入框',
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );

      // 验证前缀图标显示
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.text('带图标输入框'), findsOneWidget);
    });

    testWidgets('表单验证测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Form(
              child: CustomTextField(
                label: '验证输入框',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '此字段不能为空';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // 找到TextFormField并触发验证
      final formField = find.byType(TextFormField);
      expect(formField, findsOneWidget);
      
      // 测试空值验证
      await tester.enterText(formField, '');
      await tester.pump();
    });

    testWidgets('专用文本框变体测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                EmailTextField(),
                PasswordTextField(),
                SearchTextField(),
              ],
            ),
          ),
        ),
      );

      // 验证专用组件正确渲染
      expect(find.byType(EmailTextField), findsOneWidget);
      expect(find.byType(PasswordTextField), findsOneWidget);
      expect(find.byType(SearchTextField), findsOneWidget);
      
      // 验证默认图标
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('密码可见性切换测试', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PasswordTextField(),
          ),
        ),
      );

      // 初始状态应该是隐藏密码
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      
      // 点击切换按钮
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      
      // 验证图标变化为隐藏状态
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('组件集成测试', () {
    testWidgets('登录表单组件集成测试', (WidgetTester tester) async {
      final emailController = TextEditingController();
      final passwordController = TextEditingController();
      bool loginPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Form(
              child: Column(
                children: [
                  EmailTextField(
                    controller: emailController,
                  ),
                  SizedBox(height: 16),
                  PasswordTextField(
                    controller: passwordController,
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    text: '登录',
                    onPressed: () => loginPressed = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 输入邮箱和密码
      await tester.enterText(find.byType(EmailTextField), 'test@example.com');
      await tester.enterText(find.byType(PasswordTextField), 'password123');
      
      // 点击登录按钮
      await tester.tap(find.text('登录'));
      
      // 验证数据和交互
      expect(emailController.text, equals('test@example.com'));
      expect(passwordController.text, equals('password123'));
      expect(loginPressed, isTrue);
    });
  });
}