# KidWord Adventure - 图片资源获取指南

## 1. 使用开源图片资源

### Flaticon (https://www.flaticon.com/)
- 提供大量免费的矢量图标
- 需要注册账号
- 大部分图标免费，但需要标注来源

### Freepik (https://www.freepik.com/)
- 提供免费和付费的矢量图、插图
- 免费版本需要标注来源

### Icons8 (https://icons8.com/)
- 提供多种风格的图标
- 有免费版本，但功能有限制

### Openclipart (https://openclipart.org/)
- 完全免费的开源矢量图标
- 无需标注来源
- 可用于商业用途

### Wikimedia Commons (https://commons.wikimedia.org/)
- 大量公共领域和开源图片
- 需要检查每个图片的许可协议

## 2. 使用Flutter内置图标

Flutter提供了丰富的内置图标库，可以直接使用：
- Icons类包含大量Material Design图标
- CupertinoIcons类包含iOS风格图标

示例：
```dart
Icon(Icons.car)     // 汽车图标
Icon(Icons.pets)    // 动物图标
Icon(Icons.color_lens) // 颜色图标
```

## 3. 使用开源图标库

### Font Awesome Flutter
在pubspec.yaml中添加：
```yaml
dependencies:
  font_awesome_flutter: ^10.1.0
```

使用示例：
```dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

FaIcon(FontAwesomeIcons.car)      // 汽车图标
FaIcon(FontAwesomeIcons.dog)      // 狗图标
FaIcon(FontAwesomeIcons.apple)    // 苹果图标
```

## 4. 生成简单的矢量图标

### 使用Flutter Custom Paint

可以创建自定义的简单图标：

```dart
class SimpleCarIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const SimpleCarIcon({Key? key, this.size = 50, this.color = Colors.blue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CarPainter(color: color),
    );
  }
}

class CarPainter extends CustomPainter {
  final Color color;
  
  CarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 绘制简单的汽车形状
    final rect = Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.4);
    canvas.drawRect(rect, paint);
    
    // 绘制车顶
    final roof = Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.6, size.height * 0.4);
    canvas.drawRect(roof, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## 5. 使用SVG图标

### 添加依赖
在pubspec.yaml中添加：
```yaml
dependencies:
  flutter_svg: ^2.0.0
```

### 使用示例
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/icons/car.svg',
  width: 100,
  height: 100,
)
```

## 6. 推荐的图片资源获取策略

### 对于车辆类 (vehicles)
- 使用Icons.directions_car, Icons.local_shipping, Icons.train, Icons.pedal_bike
- 或从Openclipart搜索"car", "truck", "bus", "bike", "train"

### 对于动物类 (animals)
- 使用Icons.pets, Icons.eco, Icons.forest
- 或从Openclipart搜索"dog", "cat", "elephant", "lion", "bird", "fish"

### 对于颜色类 (colors)
- 使用纯色方块或圆圈
- 或从Openclipart搜索"red", "blue", "green", "yellow", "orange"

### 对于数字类 (numbers)
- 使用Flutter内置的文本显示
- 或创建简单的数字图标

### 对于食物类 (food)
- 使用Icons.restaurant, Icons.local_pizza, Icons.local_cafe
- 或从Openclipart搜索"apple", "banana", "bread", "milk", "egg"

### 对于身体部位类 (body)
- 使用Icons.accessibility, Icons.face, Icons.handshake
- 或从Openclipart搜索"head", "hand", "foot", "eye", "nose"

### 对于玩具类 (toys)
- 使用Icons.toys
- 或从Openclipart搜索"ball", "doll", "blocks", "teddy bear"

## 7. 图片资源命名规范

为了保持一致性，建议使用以下命名规范：
- 文件名全部小写
- 使用下划线分隔单词
- 与words.json中的text字段保持一致

示例：
- car.png
- red.png
- apple.png
- teddy_bear.png

## 8. 图片尺寸建议

- 推荐尺寸：200x200像素
- 格式：PNG（支持透明背景）
- 保持图片简洁明了，适合儿童识别

## 9. 获取资源的步骤

1. 访问Openclipart网站 (https://openclipart.org/)
2. 搜索相关关键词
3. 选择合适的图片
4. 下载SVG格式
5. 如需要，使用工具转换为PNG格式
6. 调整尺寸为200x200像素
7. 保存到assets/images/目录下
8. 确保文件名与words.json中的text字段一致

## 10. 替代方案：使用Emoji

对于快速原型开发，可以考虑使用Emoji作为图片替代：
```dart
Text('🚗', style: TextStyle(fontSize: 100)) // 汽车
Text('🐶', style: TextStyle(fontSize: 100)) // 狗
Text('🍎', style: TextStyle(fontSize: 100)) // 苹果
```

这种方式不需要图片资源，但视觉效果可能不如专门的图标。