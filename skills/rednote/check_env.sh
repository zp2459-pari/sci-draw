#!/bin/bash
# 小红书 MCP 环境检查脚本 (WSL 连 Windows localhost 直通版)

# 直接使用 127.0.0.1，依靠 WSL2 的 localhost 转发机制连通 Windows
MCP_URL="${XHS_MCP_URL:-http://127.0.0.1:18060/mcp}"

echo "=== 1. 检查 Windows MCP 连通性 ==="
echo "正在尝试连接 Windows 服务: $MCP_URL"

rm -f /tmp/xhs_headers

# 重点：所有 curl 都加上 --noproxy "*" 防止被科学上网工具拦截
SESSION_ID=$(curl --noproxy "*" -m 5 -s -D /tmp/xhs_headers -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"openclaw","version":"1.0"}},"id":1}' > /dev/null && grep -i 'Mcp-Session-Id' /tmp/xhs_headers | tr -d '\r' | awk '{print $2}')

if [ -z "$SESSION_ID" ]; then
  echo "❌ 无法连接到 Windows 上的 MCP 服务！"
  exit 1
fi

echo "✅ 成功连上 Windows MCP 服务！Session ID: $SESSION_ID"

echo "=== 2. 检查小红书登录状态 ==="
curl --noproxy "*" -m 5 -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}' > /dev/null

LOGIN_RESULT=$(curl --noproxy "*" -m 10 -s -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"check_login_status","arguments":{}},"id":2}')

if echo "$LOGIN_RESULT" | grep -q "未登录"; then
  echo "❌ 检测到未登录！"
  echo "👉 请在 Windows 上的黑框框里获取二维码，并用手机小红书 App 扫码登录。"
  exit 2
else
  echo "✅ 账号已登录，OpenClaw 可以开始发文了！"
  exit 0
fi