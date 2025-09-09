#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
单词图片批量生成脚本
使用AI生成适合的小尺寸图片并压缩存储到assets目录
"""

import os
import json
import requests
import time
from PIL import Image
import io
from urllib.parse import quote
import argparse

class WordImageGenerator:
    def __init__(self):
        self.target_size = (200, 200)  # 目标图片尺寸
        self.quality = 85  # JPEG压缩质量
        self.output_dir = "../assets/images/words"
        self.words_data_path = "../assets/data/words.json"
        
        # 确保输出目录存在
        os.makedirs(self.output_dir, exist_ok=True)
        
    def load_words_from_json(self):
        """从words.json加载单词数据"""
        try:
            with open(self.words_data_path, 'r', encoding='utf-8') as f:
                words_data = json.load(f)
                words = []
                for word_obj in words_data:
                    if isinstance(word_obj, dict):
                        words.append(word_obj.get('text', ''))
                    else:
                        words.append(str(word_obj))
                return [w for w in words if w.strip()]
        except Exception as e:
            print(f"加载单词数据失败: {e}")
            # 返回默认单词列表
            return self.get_default_words()
    
    def get_default_words(self):
        """获取默认单词列表"""
        return [
            # 动物类
            'cat', 'dog', 'bird', 'fish', 'elephant', 'lion', 'tiger', 'bear',
            'rabbit', 'horse', 'cow', 'pig', 'sheep', 'goat', 'chicken', 'duck',
            'monkey', 'panda', 'wolf', 'fox', 'deer', 'giraffe', 'zebra',
            
            # 食物类  
            'apple', 'banana', 'orange', 'grape', 'strawberry', 'watermelon',
            'bread', 'cake', 'pizza', 'hamburger', 'sandwich', 'milk', 'water',
            'tea', 'coffee', 'rice', 'noodles', 'soup', 'salad', 'meat',
            
            # 交通工具
            'car', 'bus', 'train', 'plane', 'bike', 'boat', 'ship', 'truck',
            'motorcycle', 'taxi', 'subway', 'helicopter', 'rocket',
            
            # 日常物品
            'book', 'pen', 'pencil', 'bag', 'phone', 'computer', 'watch',
            'glasses', 'shoes', 'hat', 'shirt', 'dress', 'chair', 'table',
            'bed', 'door', 'window', 'lamp', 'clock', 'camera', 'key',
            
            # 自然物
            'sun', 'moon', 'star', 'cloud', 'rain', 'snow', 'wind', 'fire',
            'water', 'tree', 'flower', 'grass', 'mountain', 'river', 'sea',
            'beach', 'forest', 'desert', 'island', 'rainbow',
            
            # 颜色
            'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink',
            'black', 'white', 'gray', 'brown',
            
            # 数字
            'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
            'nine', 'ten',
            
            # 基础动词
            'run', 'walk', 'jump', 'fly', 'swim', 'eat', 'drink', 'sleep',
            'read', 'write', 'sing', 'dance', 'play', 'work', 'study',
            
            # 地点
            'home', 'school', 'park', 'hospital', 'restaurant', 'shop',
            'library', 'museum', 'cinema', 'beach', 'garden', 'kitchen',
            
            # 天气
            'sunny', 'cloudy', 'rainy', 'snowy', 'windy', 'hot', 'cold', 'warm',
            
            # 形容词
            'big', 'small', 'tall', 'short', 'long', 'happy', 'sad', 'good',
            'bad', 'new', 'old', 'fast', 'slow', 'clean', 'dirty'
        ]
    
    def generate_with_pollinations(self, word, meaning=""):
        """使用Pollinations AI生成图片"""
        try:
            # 构建优化的提示词 - 生成实际物体图片，不是文字
            prompt = self._build_image_prompt(word, meaning)
            
            # URL编码
            encoded_prompt = quote(prompt)
            url = f"https://image.pollinations.ai/prompt/{encoded_prompt}?width=400&height=400&model=flux&enhance=true"
            
            print(f"正在生成 '{word}' 的图片...")
            print(f"提示词: {prompt}")
            
            # 发送请求
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            
            # 处理图片
            image = Image.open(io.BytesIO(response.content))
            return self.process_image(image, word)
            
        except Exception as e:
            print(f"生成 '{word}' 图片失败: {e}")
            return None
    
    def _build_image_prompt(self, word, meaning=""):
        """构建专门的图像提示词，确保生成实际物体而非文字"""
        # 基础描述映射
        word_descriptions = {
            # 交通工具
            'car': 'a red car, automobile, vehicle, side view, clean background',
            'truck': 'a blue truck, lorry, delivery truck, side view, clean background',
            'bus': 'a yellow school bus, public transport, side view, clean background', 
            'bike': 'a bicycle, two wheels, side view, clean background',
            'train': 'a train, locomotive, railway, side view, clean background',
            'plane': 'an airplane, aircraft flying, side view, blue sky background',
            'boat': 'a sailboat, ship on water, side view, ocean background',
            
            # 动物
            'cat': 'a cute cat, kitten, domestic cat sitting, furry animal',
            'dog': 'a friendly dog, puppy, domestic dog sitting, furry animal',
            'elephant': 'a gray elephant, large mammal, side view, safari background',
            'lion': 'a lion, big cat, mane, king of jungle, side view',
            'monkey': 'a monkey, primate, sitting on branch, jungle background',
            'bird': 'a colorful bird, flying bird, wings spread, blue sky',
            'fish': 'a tropical fish, colorful fish swimming, underwater scene',
            
            # 食物
            'apple': 'a red apple, fresh fruit, whole apple with stem',
            'banana': 'a yellow banana, curved fruit, peeled banana',
            'bread': 'a loaf of bread, sliced bread, bakery item',
            'milk': 'a glass of white milk, dairy product, transparent glass',
            'egg': 'a white egg, chicken egg, oval shaped',
            
            # 颜色（用彩色物体表示）
            'red': 'red color, bright red apple, red rose, vibrant red',
            'blue': 'blue color, blue sky, blue ocean, bright blue',
            'green': 'green color, green grass, green leaves, vibrant green',
            'yellow': 'yellow color, yellow sun, yellow banana, bright yellow',
            'orange': 'orange color, orange fruit, sunset orange, vibrant orange',
            
            # 数字（用数字符号表示但设计感强）
            'one': 'number 1, single item, one apple, minimalist design',
            'two': 'number 2, two apples, pair of items, minimalist design',
            'three': 'number 3, three balloons, trio of items, minimalist design',
            'four': 'number 4, four flowers, group of four, minimalist design',
            'five': 'number 5, five stars, group of five, minimalist design',
            
            # 身体部位
            'head': 'human head silhouette, profile view, simple illustration',
            'hand': 'human hand, open palm, five fingers, side view',
            'foot': 'human foot, side view, simple illustration',
            'eye': 'human eye, detailed eye with eyelashes, close-up',
            'nose': 'human nose, profile view, simple illustration',
            
            # 玩具
            'ball': 'a colorful ball, sphere, toy ball, bright colors',
            'doll': 'a cute doll, toy doll, stuffed doll, children toy',
            'blocks': 'building blocks, colorful toy blocks, stacked cubes',
            'teddy bear': 'a brown teddy bear, stuffed bear, cute toy bear',
            
            # 游乐设施
            'slide': 'a playground slide, children slide, colorful playground equipment',
            'swing': 'a playground swing, swing set, children playground',
            'seesaw': 'a seesaw, teeter-totter, playground equipment, balance beam',
        }
        
        # 获取专门的描述或使用通用描述
        if word.lower() in word_descriptions:
            base_description = word_descriptions[word.lower()]
        else:
            # 通用描述，确保生成实际物体
            base_description = f"a {word}, real object, photograph style, clear image"
            if meaning:
                base_description = f"a {word}, {meaning}, real object, photograph style"
        
        # 添加质量提升词汇
        quality_terms = "high quality, detailed, clear, professional photography, studio lighting, clean background, centered composition"
        
        # 明确排除文字
        no_text = "no text, no words, no letters, no writing, no typography"
        
        return f"{base_description}, {quality_terms}, {no_text}"
    
    def process_image(self, image, word):
        """处理图片：调整大小、压缩、保存"""
        try:
            # 转换为RGB（如果是RGBA）
            if image.mode == 'RGBA':
                background = Image.new('RGB', image.size, (255, 255, 255))
                background.paste(image, mask=image.split()[-1])
                image = background
            
            # 调整大小
            image = image.resize(self.target_size, Image.Resampling.LANCZOS)
            
            # 保存为优化的JPEG
            output_path = os.path.join(self.output_dir, f"{word}.jpg")
            image.save(output_path, 'JPEG', quality=self.quality, optimize=True)
            
            print(f"✓ 已保存: {output_path}")
            return output_path
            
        except Exception as e:
            print(f"处理图片失败: {e}")
            return None
    
    def generate_fallback_image(self, word):
        """生成备用图片（简单的图标式插图）"""
        try:
            from PIL import ImageDraw, ImageFont
            
            # 创建图片
            image = Image.new('RGB', self.target_size, (240, 248, 255))  # 淡蓝色背景
            draw = ImageDraw.Draw(image)
            
            # 根据单词类型选择颜色和简单图形
            word_lower = word.lower()
            
            if word_lower in ['car', 'truck', 'bus', 'bike', 'train', 'plane', 'boat']:
                # 交通工具 - 绘制简单车辆形状
                self._draw_vehicle_icon(draw, word_lower)
            elif word_lower in ['cat', 'dog', 'elephant', 'lion', 'monkey', 'bird', 'fish']:
                # 动物 - 绘制简单动物形状  
                self._draw_animal_icon(draw, word_lower)
            elif word_lower in ['apple', 'banana', 'bread', 'milk', 'egg']:
                # 食物 - 绘制简单食物形状
                self._draw_food_icon(draw, word_lower)
            elif word_lower in ['red', 'blue', 'green', 'yellow', 'orange']:
                # 颜色 - 绘制彩色圆形
                self._draw_color_icon(draw, word_lower)
            elif word_lower in ['one', 'two', 'three', 'four', 'five']:
                # 数字 - 绘制数字符号
                self._draw_number_icon(draw, word_lower)
            else:
                # 其他 - 绘制通用图标
                self._draw_generic_icon(draw, word)
            
            # 保存
            output_path = os.path.join(self.output_dir, f"{word}.jpg")
            image.save(output_path, 'JPEG', quality=self.quality, optimize=True)
            
            print(f"✓ 已生成备用图标: {output_path}")
            return output_path
            
        except Exception as e:
            print(f"生成备用图片失败: {e}")
            return None
    
    def _draw_vehicle_icon(self, draw, word):
        """绘制交通工具图标"""
        center_x, center_y = self.target_size[0] // 2, self.target_size[1] // 2
        
        if word == 'car':
            # 简单的汽车形状
            draw.rectangle([center_x-60, center_y-20, center_x+60, center_y+10], fill=(70, 130, 180))
            draw.rectangle([center_x-40, center_y-35, center_x+20, center_y-20], fill=(70, 130, 180))
            # 车轮
            draw.ellipse([center_x-50, center_y+5, center_x-30, center_y+25], fill=(50, 50, 50))
            draw.ellipse([center_x+30, center_y+5, center_x+50, center_y+25], fill=(50, 50, 50))
        elif word == 'bus':
            # 公交车
            draw.rectangle([center_x-70, center_y-30, center_x+70, center_y+20], fill=(255, 165, 0))
            # 窗户
            for i in range(-2, 3):
                draw.rectangle([center_x+i*25-8, center_y-25, center_x+i*25+8, center_y-10], fill=(200, 200, 255))
        elif word == 'bike':
            # 自行车轮子
            draw.ellipse([center_x-50, center_y-10, center_x-10, center_y+30], outline=(70, 130, 180), width=5)
            draw.ellipse([center_x+10, center_y-10, center_x+50, center_y+30], outline=(70, 130, 180), width=5)
            # 车架
            draw.line([center_x-30, center_y+10, center_x+30, center_y+10], fill=(70, 130, 180), width=3)
    
    def _draw_animal_icon(self, draw, word):
        """绘制动物图标"""
        center_x, center_y = self.target_size[0] // 2, self.target_size[1] // 2
        
        if word == 'cat':
            # 猫头
            draw.ellipse([center_x-30, center_y-20, center_x+30, center_y+20], fill=(255, 140, 0))
            # 猫耳朵
            draw.polygon([(center_x-25, center_y-15), (center_x-35, center_y-35), (center_x-15, center_y-25)], fill=(255, 140, 0))
            draw.polygon([(center_x+15, center_y-25), (center_x+35, center_y-35), (center_x+25, center_y-15)], fill=(255, 140, 0))
            # 眼睛
            draw.ellipse([center_x-15, center_y-10, center_x-5, center_y], fill=(0, 0, 0))
            draw.ellipse([center_x+5, center_y-10, center_x+15, center_y], fill=(0, 0, 0))
        elif word == 'dog':
            # 狗头
            draw.ellipse([center_x-35, center_y-15, center_x+35, center_y+25], fill=(139, 69, 19))
            # 狗耳朵
            draw.ellipse([center_x-45, center_y-25, center_x-25, center_y-5], fill=(139, 69, 19))
            draw.ellipse([center_x+25, center_y-25, center_x+45, center_y-5], fill=(139, 69, 19))
        elif word == 'bird':
            # 鸟身体
            draw.ellipse([center_x-25, center_y-10, center_x+35, center_y+20], fill=(255, 215, 0))
            # 翅膀
            draw.ellipse([center_x-15, center_y-5, center_x+5, center_y+15], fill=(255, 165, 0))
            # 鸟嘴
            draw.polygon([(center_x+30, center_y), (center_x+45, center_y-5), (center_x+45, center_y+5)], fill=(255, 140, 0))
    
    def _draw_food_icon(self, draw, word):
        """绘制食物图标"""
        center_x, center_y = self.target_size[0] // 2, self.target_size[1] // 2
        
        if word == 'apple':
            # 苹果
            draw.ellipse([center_x-30, center_y-25, center_x+30, center_y+25], fill=(255, 0, 0))
            # 叶子
            draw.ellipse([center_x-5, center_y-35, center_x+15, center_y-25], fill=(0, 128, 0))
        elif word == 'banana':
            # 香蕉
            points = [(center_x-40, center_y+20), (center_x-30, center_y-20), (center_x, center_y-25), 
                     (center_x+30, center_y-15), (center_x+35, center_y+10), (center_x+20, center_y+25),
                     (center_x-20, center_y+25)]
            draw.polygon(points, fill=(255, 255, 0))
    
    def _draw_color_icon(self, draw, word):
        """绘制颜色图标"""
        center_x, center_y = self.target_size[0] // 2, self.target_size[1] // 2
        
        colors = {
            'red': (255, 0, 0),
            'blue': (0, 0, 255), 
            'green': (0, 255, 0),
            'yellow': (255, 255, 0),
            'orange': (255, 165, 0)
        }
        
        color = colors.get(word, (128, 128, 128))
        draw.ellipse([center_x-40, center_y-40, center_x+40, center_y+40], fill=color)
    
    def _draw_number_icon(self, draw, word):
        """绘制数字图标"""
        center_x, center_y = self.target_size[0] // 2, self.target_size[1] // 2
        
        numbers = {'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5'}
        number_text = numbers.get(word, '?')
        
        # 绘制数字
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 80)
        except:
            font = ImageFont.load_default()
        
        bbox = draw.textbbox((0, 0), number_text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = center_x - text_width // 2
        y = center_y - text_height // 2
        
        draw.text((x, y), number_text, fill=(70, 130, 180), font=font)
    
    def _draw_generic_icon(self, draw, word):
        """绘制通用图标（小字体单词）"""
        center_x, center_y = self.target_size[0] // 2, self.target_size[1] // 2
        
        # 绘制背景圆形
        draw.ellipse([center_x-50, center_y-50, center_x+50, center_y+50], 
                    fill=(200, 220, 240), outline=(70, 130, 180), width=3)
        
        # 绘制小字体单词
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 16)
        except:
            font = ImageFont.load_default()
        
        bbox = draw.textbbox((0, 0), word.upper(), font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        x = center_x - text_width // 2
        y = center_y - text_height // 2
        
        draw.text((x, y), word.upper(), fill=(70, 130, 180), font=font)
    
    def generate_all_images(self, use_ai=True, delay=1.0):
        """批量生成所有单词的图片"""
        words = self.load_words_from_json()
        total_words = len(words)
        success_count = 0
        
        print(f"开始生成 {total_words} 个单词的图片...")
        print(f"目标尺寸: {self.target_size}")
        print(f"输出目录: {self.output_dir}")
        print(f"压缩质量: {self.quality}%")
        print(f"使用AI生成: {'是' if use_ai else '否'}")
        print("-" * 50)
        
        for i, word in enumerate(words, 1):
            print(f"[{i}/{total_words}] 处理单词: {word}")
            
            # 检查是否已存在
            existing_path = os.path.join(self.output_dir, f"{word}.jpg")
            if os.path.exists(existing_path):
                print(f"  - 图片已存在，跳过")
                success_count += 1
                continue
            
            success = False
            
            if use_ai:
                # 尝试AI生成
                result = self.generate_with_pollinations(word)
                if result:
                    success = True
                    success_count += 1
                else:
                    # AI失败，生成备用图片
                    print(f"  - AI生成失败，使用备用方案")
                    result = self.generate_fallback_image(word)
                    if result:
                        success = True
                        success_count += 1
            else:
                # 直接生成备用图片
                result = self.generate_fallback_image(word)
                if result:
                    success = True
                    success_count += 1
            
            if not success:
                print(f"  - ✗ 生成失败")
            
            # 添加延迟避免请求过快
            if use_ai and i < total_words:
                time.sleep(delay)
        
        print("-" * 50)
        print(f"生成完成！成功: {success_count}/{total_words}")
        
        # 生成图片索引文件
        self.generate_image_index()
    
    def generate_image_index(self):
        """生成图片索引文件"""
        try:
            index_data = {}
            
            # 扫描图片目录
            for filename in os.listdir(self.output_dir):
                if filename.endswith('.jpg'):
                    word = filename[:-4]  # 去掉.jpg扩展名
                    index_data[word] = f"assets/images/words/{filename}"
            
            # 保存索引文件
            index_path = os.path.join(self.output_dir, "index.json")
            with open(index_path, 'w', encoding='utf-8') as f:
                json.dump(index_data, f, indent=2, ensure_ascii=False)
            
            print(f"✓ 已生成图片索引: {index_path}")
            print(f"  - 共索引 {len(index_data)} 张图片")
            
        except Exception as e:
            print(f"生成索引文件失败: {e}")

def main():
    parser = argparse.ArgumentParser(description='批量生成单词图片')
    parser.add_argument('--no-ai', action='store_true', help='不使用AI，直接生成文字图片')
    parser.add_argument('--delay', type=float, default=1.0, help='AI请求间隔（秒）')
    parser.add_argument('--size', type=str, default='200x200', help='图片尺寸，格式: 宽x高')
    parser.add_argument('--quality', type=int, default=85, help='JPEG压缩质量 (1-100)')
    
    args = parser.parse_args()
    
    # 解析尺寸参数
    try:
        width, height = map(int, args.size.split('x'))
        target_size = (width, height)
    except:
        print("错误的尺寸格式，使用默认值 200x200")
        target_size = (200, 200)
    
    # 创建生成器
    generator = WordImageGenerator()
    generator.target_size = target_size
    generator.quality = args.quality
    
    # 开始生成
    generator.generate_all_images(
        use_ai=not args.no_ai,
        delay=args.delay
    )

if __name__ == "__main__":
    main()