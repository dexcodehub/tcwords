# 单词图片批量生成工具

## 📋 功能说明

这个工具用于批量生成单词图片，并优化存储到Flutter项目的静态资源目录中。

## 🚀 快速开始

### 1. 安装依赖

```bash
cd tools
pip install -r requirements.txt
```

### 2. 生成图片

#### 使用AI生成（推荐）
```bash
python generate_word_images.py
```

#### 只生成文字图片（无网络依赖）
```bash
python generate_word_images.py --no-ai
```

#### 自定义参数
```bash
# 设置图片尺寸为150x150，压缩质量90%，请求间隔0.5秒
python generate_word_images.py --size 150x150 --quality 90 --delay 0.5
```

### 3. 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--no-ai` | 不使用AI，直接生成文字图片 | false |
| `--delay` | AI请求间隔（秒） | 1.0 |
| `--size` | 图片尺寸（宽x高） | 200x200 |
| `--quality` | JPEG压缩质量(1-100) | 85 |

## 📁 输出结构

生成的文件将保存在 `../assets/images/words/` 目录：

```
assets/images/words/
├── index.json          # 图片索引文件
├── cat.jpg            # 单词图片
├── dog.jpg
├── apple.jpg
└── ...
```

## 🎯 图片特点

- **尺寸统一**: 默认200x200像素，适合移动端显示
- **格式优化**: JPEG格式，85%质量，平衡清晰度和文件大小
- **风格一致**: 简洁的插画风格，适合学习应用
- **快速加载**: 预压缩，平均每张图片5-15KB

## 🔧 自定义配置

### 修改单词列表

1. 编辑 `../assets/data/words.json` 文件
2. 或在脚本中修改 `get_default_words()` 方法

### 修改图片风格

在 `generate_with_pollinations()` 方法中修改提示词：

```python
prompt += ", simple illustration, clean background, educational style, cartoon style, bright colors, minimalist, icon style"
```

### 添加新的AI服务

在脚本中添加新的生成方法，例如：

```python
def generate_with_custom_ai(self, word, meaning=""):
    # 实现自定义AI服务
    pass
```

## 📊 生成统计

脚本会显示详细的生成进度和统计：

```
开始生成 120 个单词的图片...
目标尺寸: (200, 200)
输出目录: ../assets/images/words
压缩质量: 85%
使用AI生成: 是
--------------------------------------------------
[1/120] 处理单词: cat
正在生成 'cat' 的图片...
✓ 已保存: ../assets/images/words/cat.jpg
[2/120] 处理单词: dog
...
--------------------------------------------------
生成完成！成功: 118/120
✓ 已生成图片索引: ../assets/images/words/index.json
  - 共索引 118 张图片
```

## 🛠️ 故障排除

### 1. 网络连接问题
```bash
# 使用备用方案（文字图片）
python generate_word_images.py --no-ai
```

### 2. 图片生成失败
- 检查网络连接
- 增加请求延迟: `--delay 2.0`
- 使用备用AI服务或文字图片

### 3. 依赖安装问题
```bash
# macOS用户
brew install python-tk

# Ubuntu用户  
sudo apt-get install python3-pil python3-pil.imagetk
```

## 🎨 图片质量优化建议

1. **尺寸选择**:
   - 小尺寸设备: 150x150
   - 标准设备: 200x200  
   - 高清设备: 300x300

2. **压缩质量**:
   - 快速原型: 70-80%
   - 生产环境: 85-90%
   - 高质量: 90-95%

3. **批量处理**:
   - 建议分批处理，每批50-100个单词
   - 设置适当的请求延迟避免API限制

## 📱 在Flutter中使用

生成图片后，在Flutter项目中这样使用：

```dart
import 'package:tcword/src/widgets/learning/static_word_image.dart';

// 显示单词图片
StaticWordImage(
  word: word,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)
```

## 🔄 更新图片

当需要更新图片时：

1. 删除现有图片文件
2. 重新运行生成脚本
3. 新的 `index.json` 会自动生成

## 💡 高级技巧

### 批量重新生成特定单词
```python
# 在脚本中添加过滤逻辑
words_to_regenerate = ['cat', 'dog', 'apple']
words = [w for w in words if w in words_to_regenerate]
```

### 不同风格的图片
```python
# 修改提示词生成不同风格
style_prompts = {
    'cartoon': 'cartoon style, colorful, fun',
    'realistic': 'photorealistic, detailed',
    'minimal': 'minimalist, clean, simple'
}
```