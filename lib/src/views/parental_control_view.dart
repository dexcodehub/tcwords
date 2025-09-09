import 'package:flutter/material.dart';

class ParentalControlView extends StatefulWidget {
  const ParentalControlView({super.key});

  @override
  State<ParentalControlView> createState() => _ParentalControlViewState();
}

class _ParentalControlViewState extends State<ParentalControlView> {
  bool _isTimerEnabled = false;
  int _timeLimit = 30; // 默认30分钟
  bool _isContentFilterEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parental Control'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 学习时间设置
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Study Time Limit',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Enable time limit: ${_isTimerEnabled ? "On" : "Off"}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Switch(
                            value: _isTimerEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isTimerEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isTimerEnabled) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Time limit: $_timeLimit minutes',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Slider(
                          value: _timeLimit.toDouble(),
                          min: 10,
                          max: 120,
                          divisions: 11,
                          label: '$_timeLimit minutes',
                          onChanged: (value) {
                            setState(() {
                              _timeLimit = value.toInt();
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 内容过滤设置
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Content Filter',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Enable content filter',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Switch(
                            value: _isContentFilterEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isContentFilterEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select allowed categories:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      // 这里应该从实际的分类数据中生成复选框
                      // 为了演示，我们使用静态数据
                      const CheckboxListTile(
                        title: Text('Vehicles'),
                        value: true,
                        onChanged: null,
                      ),
                      const CheckboxListTile(
                        title: Text('Animals'),
                        value: true,
                        onChanged: null,
                      ),
                      const CheckboxListTile(
                        title: Text('Playground'),
                        value: true,
                        onChanged: null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 学习报告按钮
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 导航到学习报告页面
                  },
                  child: const Text('View Learning Report'),
                ),
              ),
              const SizedBox(height: 20), // 添加一些底部间距
            ],
          ),
        ),
      ),
    );
  }
}