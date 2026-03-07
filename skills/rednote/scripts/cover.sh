#!/bin/bash
# 小红书封面图生成脚本 (本地拼图版)
# 功能：将指定的本地图片裁剪为 3:2，并在下半部分 3:2 区域拼接标题文字，输出 3:4 完整封面
# 
# 用法:
#   bash cover.sh "标题文字" "/mnt/c/xhs_media/raw.jpg" "/mnt/c/xhs_media/cover.png" "#F5E6D0" "#6B4226"

set -e

TITLE="${1:-}"
RAW_IMAGE="${2:-}"
OUTPUT="${3:-/tmp/xhs_cover.png}"
BG_COLOR="${4:-#FFFFFF}"
TEXT_COLOR="${5:-#1A1A1A}"

# 去除可能包含的 __USER_IMAGE__: 前缀，兼容旧指令
USER_IMAGE_PATH="${RAW_IMAGE#__USER_IMAGE__:}"

if [ -z "$TITLE" ] || [ -z "$USER_IMAGE_PATH" ]; then
  echo "❌ 错误: 参数缺失"
  echo "用法: bash $0 \"标题文字\" \"图片绝对路径\" [输出路径] [底色] [字色]"
  exit 1
fi

if [ ! -f "$USER_IMAGE_PATH" ]; then
  echo "❌ 错误: 找不到源图片文件: $USER_IMAGE_PATH"
  exit 1
fi

# 检查 ImageMagick
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
  echo "❌ 错误: 未安装 ImageMagick，请先执行: sudo apt install -y imagemagick"
  exit 1
fi

MAGICK=$(command -v magick || command -v convert)

# 尺寸定义
COVER_W=1080
COVER_H=1440
TOP_W=1080
TOP_H=720
BOT_W=1080
BOT_H=720

TMP_DIR=$(mktemp -d)
AI_RESIZED="${TMP_DIR}/top.png"
TITLE_IMG="${TMP_DIR}/bot.png"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "🎨 开始制作小红书封面图..."
echo "   标题: ${TITLE}"
echo "   源图: ${USER_IMAGE_PATH}"
echo "   输出: ${OUTPUT}"

# ==================== 第1步：处理主题图片 ====================
echo "🔄 [1/3] 裁剪源图片为 3:2 比例..."
$MAGICK "$USER_IMAGE_PATH" -resize "${TOP_W}x${TOP_H}^" -gravity center -extent "${TOP_W}x${TOP_H}" "$AI_RESIZED"
echo "   ✅ 上半部分就绪"

# ==================== 第2步：生成标题区域 ====================
echo "🔄 [2/3] 生成标题文字区域..."
PAD_LEFT=60
PAD_RIGHT=60
PAD_TOP=60
PAD_BOTTOM=60
TEXT_AREA_W=$((BOT_W - PAD_LEFT - PAD_RIGHT))
TEXT_AREA_H=$((BOT_H - PAD_TOP - PAD_BOTTOM))

# 查找中文字体
FONT=$(fc-list :lang=zh -f "%{file}\n" | grep -i "bold\|heavy\|black" | head -1)
if [ -z "$FONT" ]; then
  FONT=$(fc-list :lang=zh -f "%{file}\n" | head -1)
fi
FONT_ARG=${FONT:+"-font" "$FONT"}

# 本地 Python 智能断句（无需连网）
LINEBREAK_PY="${TMP_DIR}/linebreak.py"
cat > "$LINEBREAK_PY" << 'PYEOF'
import sys, re
title = sys.argv[1]
# 按常见标点符号拆分
parts = [p for p in re.split(r'([，。！？、；：\s]+)', title) if p]
lines, current_line = [], ""
for p in parts:
    if len(current_line) + len(p) > 10 and current_line: # 超过10个字符尝试换行
        if not re.match(r'^[，。！？、；：\s]+$', p): # 标点不作为行首
            lines.append(current_line)
            current_line = p
            continue
    current_line += p
if current_line:
    lines.append(current_line)
print('\n'.join(lines))
PYEOF

WRAPPED_TITLE=$(python3 "$LINEBREAK_PY" "$TITLE")
FONT_SIZE=120

TEXT_BLOCK="${TMP_DIR}/text_block.png"
render_text_block() {
  $MAGICK -background "$BG_COLOR" -fill "$TEXT_COLOR" $FONT_ARG \
    -pointsize "$FONT_SIZE" -interline-spacing "$((FONT_SIZE / 4))" \
    -gravity SouthWest label:"$WRAPPED_TITLE" "$TEXT_BLOCK"
}

render_text_block
# 动态缩小字号以适配区域
while [ $($MAGICK identify -format "%h" "$TEXT_BLOCK") -gt "$TEXT_AREA_H" ] || [ $($MAGICK identify -format "%w" "$TEXT_BLOCK") -gt "$TEXT_AREA_W" ]; do
  if [ "$FONT_SIZE" -le 40 ]; then break; fi
  FONT_SIZE=$((FONT_SIZE - 10))
  render_text_block
done

# 纯色底板 + 文字块合并
$MAGICK -size "${BOT_W}x${BOT_H}" "xc:${BG_COLOR}" \
  "$TEXT_BLOCK" -gravity SouthWest -geometry "+${PAD_LEFT}+${PAD_BOTTOM}" -composite "$TITLE_IMG"
echo "   ✅ 下半部分就绪"

# ==================== 第3步：上下拼接 ====================
echo "🔄 [3/3] 拼接封面图..."
$MAGICK "$AI_RESIZED" "$TITLE_IMG" -append "$OUTPUT"

echo "✅ 封面图生成完成！路径: ${OUTPUT}"