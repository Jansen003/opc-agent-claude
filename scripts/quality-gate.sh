#!/bin/bash
# OPC Agent 一致性检查（Claude Code 版）
# 检查 prompts/ 目录中的角色提示词文件之间的引用一致性和完整性

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROMPTS_DIR="$PROJECT_DIR/prompts"
KNOWLEDGE="${OPC_KNOWLEDGE_PATH:-$HOME/code/opc/opc-knowledge}"

ERRORS=0
WARNINGS=0

echo "=== OPC Agent 一致性检查（Claude Code 版） ==="
echo ""

# ---------- 1. 文件完整性检查 ----------
echo "📋 角色文件完整性检查："
for prompt_file in "$PROMPTS_DIR"/*.md; do
  agent_name=$(basename "$prompt_file" .md)
  if ! grep -qE "## (核心职责|核心能力|你的定位)" "$prompt_file" 2>/dev/null && \
     ! grep -qE "## (红线|协作接口|产出规则|工作流程)" "$prompt_file" 2>/dev/null; then
    echo "  ❌ $agent_name — 缺少核心职责/红线/协作接口等关键章节"
    ERRORS=$((ERRORS + 1))
  fi
done
if [ $ERRORS -eq 0 ]; then
  echo "  ✅ 所有角色文件关键章节完整"
fi

echo ""

# ---------- 2. 角色文件 vs CLAUDE.md 引用 ----------
echo "🔗 角色引用一致性检查："
ACTUAL_PROMPTS=()
for f in "$PROMPTS_DIR"/*.md; do
  ACTUAL_PROMPTS+=("$(basename "$f" .md)")
done

echo "  实际角色数: ${#ACTUAL_PROMPTS[@]}"
echo "  实际角色列表: ${ACTUAL_PROMPTS[*]}"

for a in "${ACTUAL_PROMPTS[@]}"; do
  # 匹配文件名（直接匹配）和驼峰名（通过 python 转换，环境变量传参防注入）
  search_name=$(AGENT_NAME="$a" python3 -c 'import os; name=os.environ["AGENT_NAME"]; print(name.replace("-", " ").title().replace(" ", ""))' 2>/dev/null)
  if ! grep -qi "| $a " "$PROJECT_DIR/CLAUDE.md" 2>/dev/null && \
     ! grep -qi "| $search_name " "$PROJECT_DIR/CLAUDE.md" 2>/dev/null; then
    echo "  ⚠️  $a 是实际存在的角色，但 CLAUDE.md 中的团队表未引用"
    WARNINGS=$((WARNINGS + 1))
  fi
done

echo ""

# ---------- 3. 知识库路径检查 ----------
echo "📚 知识库路径检查："
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  MISSING_DIRS=0
  while IFS= read -r dir; do
    if [[ "$dir" =~ ^[0-9]{2}- ]]; then
      if [ ! -d "$KNOWLEDGE/$dir" ]; then
        echo "  ❌ CLAUDE.md 引用知识库目录 $dir，但实际路径 $KNOWLEDGE/$dir 不存在"
        MISSING_DIRS=$((MISSING_DIRS + 1))
      fi
    fi
  done < <(grep -oP '^\| \K[0-9]{2}-[^ ]+' "$CLAUDE_MD" 2>/dev/null | head -20)
  if [ "$MISSING_DIRS" -eq 0 ]; then
    echo "  ✅ 所有 CLAUDE.md 引用的知识库目录都存在"
  else
    ERRORS=$((ERRORS + MISSING_DIRS))
  fi
fi

echo ""

# ---------- 4. 红线密钥检查 ----------
echo "🔑 密钥泄露红线检查："
for prompt_file in "$PROMPTS_DIR"/*.md; do
  agent_name=$(basename "$prompt_file" .md)
  if ! grep -q "不泄露任何密钥\|不泄露.*API key" "$prompt_file" 2>/dev/null; then
    echo "  ❌ $agent_name — 缺少密钥泄露红线"
    ERRORS=$((ERRORS + 1))
  fi
done
if [ $ERRORS -eq 0 ]; then
  echo "  ✅ 所有角色都有密钥泄露红线"
fi

echo ""
echo "===================="
echo "结果：$ERRORS 个错误，$WARNINGS 个警告"
if [ $ERRORS -eq 0 ]; then
  echo "✅ Agent 一致性检查通过"
  exit 0
else
  echo "❌ Agent 一致性检查失败 ($ERRORS 项不通过)"
  exit 1
fi
