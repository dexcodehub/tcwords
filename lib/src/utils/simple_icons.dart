import 'package:flutter/material.dart';

class SimpleIcons {
  // 简单的自定义图标绘制
  static Widget getIcon(String word, {double size = 100, Color color = Colors.blue}) {
    switch (word.toLowerCase()) {
      // 车辆类
      case 'car':
        return _CarIcon(size: size, color: color);
      case 'truck':
        return _TruckIcon(size: size, color: color);
      case 'bus':
        return _BusIcon(size: size, color: color);
      case 'bike':
        return _BikeIcon(size: size, color: color);
      case 'train':
        return _TrainIcon(size: size, color: color);
      
      // 游戏设备类
      case 'slide':
        return _SlideIcon(size: size, color: color);
      case 'swing':
        return _SwingIcon(size: size, color: color);
      case 'seesaw':
        return _SeesawIcon(size: size, color: color);
      
      // 动物类
      case 'dog':
        return _DogIcon(size: size, color: color);
      case 'cat':
        return _CatIcon(size: size, color: color);
      case 'elephant':
        return _ElephantIcon(size: size, color: color);
      case 'lion':
        return _LionIcon(size: size, color: color);
      case 'monkey':
        return _MonkeyIcon(size: size, color: color);
      case 'bird':
        return _BirdIcon(size: size, color: color);
      case 'fish':
        return _FishIcon(size: size, color: color);
      
      // 颜色类
      case 'red':
        return _ColorIcon(size: size, color: Colors.red);
      case 'blue':
        return _ColorIcon(size: size, color: Colors.blue);
      case 'green':
        return _ColorIcon(size: size, color: Colors.green);
      case 'yellow':
        return _ColorIcon(size: size, color: Colors.yellow);
      case 'orange':
        return _ColorIcon(size: size, color: Colors.orange);
      
      // 数字类
      case 'one':
        return _NumberIcon(number: '1', size: size, color: color);
      case 'two':
        return _NumberIcon(number: '2', size: size, color: color);
      case 'three':
        return _NumberIcon(number: '3', size: size, color: color);
      case 'four':
        return _NumberIcon(number: '4', size: size, color: color);
      case 'five':
        return _NumberIcon(number: '5', size: size, color: color);
      
      // 食物类
      case 'apple':
        return _AppleIcon(size: size, color: color);
      case 'banana':
        return _BananaIcon(size: size, color: color);
      case 'bread':
        return _BreadIcon(size: size, color: color);
      case 'milk':
        return _MilkIcon(size: size, color: color);
      case 'egg':
        return _EggIcon(size: size, color: color);
      
      // 身体部位类
      case 'head':
        return _HeadIcon(size: size, color: color);
      case 'hand':
        return _HandIcon(size: size, color: color);
      case 'foot':
        return _FootIcon(size: size, color: color);
      case 'eye':
        return _EyeIcon(size: size, color: color);
      case 'nose':
        return _NoseIcon(size: size, color: color);
      
      // 玩具类
      case 'ball':
        return _BallIcon(size: size, color: color);
      case 'doll':
        return _DollIcon(size: size, color: color);
      case 'toy_car':
        return _ToyCarIcon(size: size, color: color);
      case 'blocks':
        return _BlocksIcon(size: size, color: color);
      case 'teddy bear':
        return _TeddyBearIcon(size: size, color: color);
      
      // 默认情况，返回问号图标
      default:
        return Icon(Icons.help, size: size, color: color);
    }
  }
}

// 各种图标的具体实现
class _CarIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _CarIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CarPainter(color: color),
    );
  }
}

class _CarPainter extends CustomPainter {
  final Color color;

  _CarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 车身
    final bodyRect = Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.4);
    canvas.drawRect(bodyRect, paint);
    
    // 车顶
    final roofRect = Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.6, size.height * 0.3);
    canvas.drawRect(roofRect, paint);
    
    // 车轮
    final wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.8), size.width * 0.1, wheelPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.8), size.width * 0.1, wheelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 其他简单图标实现
class _TruckIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _TruckIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.local_shipping, size: size, color: color);
  }
}

class _BusIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _BusIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.directions_bus, size: size, color: color);
  }
}

class _BikeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _BikeIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.pedal_bike, size: size, color: color);
  }
}

class _TrainIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _TrainIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.train, size: size, color: color);
  }
}

class _SlideIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _SlideIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SlidePainter(color: color),
    );
  }
}

class _SlidePainter extends CustomPainter {
  final Color color;

  _SlidePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 滑梯平台
    final platformRect = Rect.fromLTWH(0, 0, size.width * 0.4, size.height * 0.2);
    canvas.drawRect(platformRect, paint);
    
    // 滑梯斜坡
    final Path path = Path();
    path.moveTo(size.width * 0.4, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.8);
    path.lineTo(size.width * 0.9, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SwingIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _SwingIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.child_care, size: size, color: color);
  }
}

class _SeesawIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _SeesawIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SeesawPainter(color: color),
    );
  }
}

class _SeesawPainter extends CustomPainter {
  final Color color;

  _SeesawPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 支点
    final pivotRect = Rect.fromLTWH(size.width * 0.45, size.height * 0.4, size.width * 0.1, size.height * 0.4);
    canvas.drawRect(pivotRect, paint);
    
    // 翘翘板
    final boardRect = Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.1);
    canvas.drawRect(boardRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 动物图标
class _DogIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _DogIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.pets, size: size, color: color);
  }
}

class _CatIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _CatIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.pets, size: size, color: color);
  }
}

class _ElephantIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _ElephantIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.eco, size: size, color: color);
  }
}

class _LionIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _LionIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.eco, size: size, color: color);
  }
}

class _MonkeyIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _MonkeyIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.eco, size: size, color: color);
  }
}

class _BirdIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _BirdIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.flight, size: size, color: color);
  }
}

class _FishIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _FishIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.water, size: size, color: color);
  }
}

// 颜色图标
class _ColorIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _ColorIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
  }
}

// 数字图标
class _NumberIcon extends StatelessWidget {
  final String number;
  final double size;
  final Color color;

  const _NumberIcon({Key? key, required this.number, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 食物图标
class _AppleIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _AppleIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.restaurant, size: size, color: color);
  }
}

class _BananaIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _BananaIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.restaurant, size: size, color: color);
  }
}

class _BreadIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _BreadIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.restaurant, size: size, color: color);
  }
}

class _MilkIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _MilkIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.local_drink, size: size, color: color);
  }
}

class _EggIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _EggIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.restaurant, size: size, color: color);
  }
}

// 身体部位图标
class _HeadIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _HeadIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.face, size: size, color: color);
  }
}

class _HandIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _HandIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.back_hand, size: size, color: color);
  }
}

class _FootIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _FootIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.accessibility, size: size, color: color);
  }
}

class _EyeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _EyeIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.visibility, size: size, color: color);
  }
}

class _NoseIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _NoseIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.face, size: size, color: color);
  }
}

// 玩具图标
class _BallIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _BallIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DollIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _DollIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.accessibility, size: size, color: color);
  }
}

class _ToyCarIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _ToyCarIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.toys, size: size, color: color);
  }
}

class _BlocksIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _BlocksIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.apps, size: size, color: color);
  }
}

class _TeddyBearIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _TeddyBearIcon({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.accessibility, size: size, color: color);
  }
}