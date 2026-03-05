#!/bin/bash
# Windows WSL 一键配置脚本
# 使用方法：在 WSL 中运行 bash windows_setup.sh

echo "=========================================="
echo "  Mnemon 远程数据库配置 (Windows WSL)"
echo "=========================================="
echo ""

# 检查是否在 WSL 中
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "⚠️  警告：您可能不在 WSL 环境中"
    echo "建议在 WSL 中运行此脚本"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 步骤 1：检查并安装 sshpass
echo "步骤 1/6: 检查 sshpass..."
if ! command -v sshpass &> /dev/null; then
    echo "  → 未找到 sshpass，正在安装..."
    sudo apt-get update -qq
    sudo apt-get install -y sshpass
    echo "  ✓ sshpass 安装完成"
else
    echo "  ✓ sshpass 已安装"
fi

# 步骤 2：设置远程连接信息
echo ""
echo "步骤 2/6: 配置远程连接信息"
REMOTE_HOST="192.168.180.127"
REMOTE_USER="agentdoc"
REMOTE_PASSWORD="js20220113"
REMOTE_PORT="22"

echo "  远程主机: $REMOTE_HOST"
echo "  用户名: $REMOTE_USER"
echo "  端口: $REMOTE_PORT"

# 步骤 3：测试 SSH 连接
echo ""
echo "步骤 3/6: 测试 SSH 连接..."
if sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -p "$REMOTE_PORT" "${REMOTE_USER}@${REMOTE_HOST}" "echo 'Connection successful'" &> /dev/null; then
    echo "  ✓ SSH 连接成功"
else
    echo "  ✗ SSH 连接失败"
    echo ""
    echo "请检查："
    echo "  1. 远程服务器是否在线"
    echo "  2. IP 地址是否正确：$REMOTE_HOST"
    echo "  3. 用户名和密码是否正确"
    echo "  4. 防火墙是否允许 SSH 连接"
    exit 1
fi

# 步骤 4：检查远程 mnemon
echo ""
echo "步骤 4/6: 检查远程服务器上的 mnemon..."
if sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$REMOTE_PORT" "${REMOTE_USER}@${REMOTE_HOST}" "command -v mnemon" &> /dev/null; then
    REMOTE_VERSION=$(sshpass -p "$REMOTE_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$REMOTE_PORT" "${REMOTE_USER}@${REMOTE_HOST}" "mnemon --version 2>&1" | head -1)
    echo "  ✓ 远程 mnemon 已安装: $REMOTE_VERSION"
else
    echo "  ✗ 远程服务器上未找到 mnemon"
    echo ""
    echo "请先在远程服务器上安装 mnemon："
    echo "  ssh $REMOTE_USER@$REMOTE_HOST"
    echo "  cd ~"
    echo "  git clone https://github.com/mnemon-dev/mnemon.git"
    echo "  cd mnemon"
    echo "  git checkout remote-db"
    echo "  make install"
    exit 1
fi

# 步骤 5：创建配置文件
echo ""
echo "步骤 5/6: 创建配置文件..."
mkdir -p ~/.mnemon

cat > ~/.mnemon/remote.conf << EOF
# Mnemon Remote Database Configuration
# Generated on $(date)
# Platform: Windows WSL

export MNEMON_REMOTE_HOST=$REMOTE_HOST
export MNEMON_REMOTE_USER=$REMOTE_USER
export MNEMON_REMOTE_PASSWORD=$REMOTE_PASSWORD
export MNEMON_REMOTE_PORT=$REMOTE_PORT
EOF

chmod 600 ~/.mnemon/remote.conf
echo "  ✓ 配置文件已创建: ~/.mnemon/remote.conf"

# 步骤 6：加载配置并测试
echo ""
echo "步骤 6/6: 测试远程连接..."
source ~/.mnemon/remote.conf

# 测试 mnemon status
if mnemon status &> /dev/null; then
    echo "  ✓ 远程 mnemon 连接成功"
else
    echo "  ⚠️  远程连接测试失败"
    echo "  请手动测试：mnemon status"
fi

# 完成
echo ""
echo "=========================================="
echo "  ✅ 配置完成！"
echo "=========================================="
echo ""
echo "下一步："
echo ""
echo "1. 加载配置（当前终端）："
echo "   source ~/.mnemon/remote.conf"
echo ""
echo "2. 测试功能："
echo "   mnemon status"
echo "   mnemon remember \"测试\" --cat general --imp 3"
echo "   mnemon recall \"测试\""
echo ""
echo "3. 永久配置（可选）："
echo "   echo 'source ~/.mnemon/remote.conf' >> ~/.bashrc"
echo ""
echo "4. 查看完整文档："
echo "   cat WINDOWS_GUIDE.md"
echo "   cat EXECUTION_CHECKLIST.md"
echo ""
echo "=========================================="
