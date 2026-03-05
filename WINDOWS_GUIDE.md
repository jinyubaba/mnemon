# Windows 环境快速开始指南

## 🪟 Windows 特别说明

本指南专门针对 Windows 环境，提供最简单的配置方法。

---

## 前置准备

### 选择执行环境

在 Windows 上，您有两个选择：

**推荐：使用 WSL (Windows Subsystem for Linux)**
- 更好的兼容性
- 完整的 Linux 工具支持
- 更稳定

**备选：使用 Git Bash**
- 无需安装 WSL
- 但 sshpass 支持有限

---

## 方案 A：使用 WSL（推荐）

### 步骤 1：启动 WSL

```bash
# 在 Windows 命令提示符或 PowerShell 中
wsl
```

### 步骤 2：在 WSL 中安装 sshpass

```bash
sudo apt-get update
sudo apt-get install sshpass
```

### 步骤 3：进入项目目录

```bash
# WSL 可以访问 Windows 文件系统
cd /mnt/c/Users/Administrator/Downloads/mnemon
```

### 步骤 4：确认在 remote-db 分支

```bash
git branch
# 应该显示 * remote-db
```

### 步骤 5：运行配置脚本

```bash
bash scripts/setup_remote.sh
```

**输入以下信息：**
- Remote host (IP or hostname): `192.168.180.127`
- Remote user: `agentdoc`
- Remote password: `js20220113`
- Remote port [22]: 直接回车（使用默认值 22）

脚本会自动：
- ✅ 测试 SSH 连接
- ✅ 检查远程服务器上的 mnemon
- ✅ 创建配置文件 `~/.mnemon/remote.conf`

### 步骤 6：加载配置

```bash
source ~/.mnemon/remote.conf
```

### 步骤 7：验证配置

```bash
# 检查环境变量
echo $MNEMON_REMOTE_HOST
# 应该输出：192.168.180.127

# 测试远程连接
mnemon status
```

**预期结果：** 显示远程服务器的数据库统计信息（JSON 格式）

### 步骤 8：测试功能

```bash
# 创建记忆
mnemon remember "Windows WSL 测试" --cat general --imp 3

# 查询记忆
mnemon recall "Windows"

# 查看状态
mnemon status
```

### 步骤 9：（可选）永久配置

```bash
# 添加到 WSL 的 bash 配置
echo "source ~/.mnemon/remote.conf" >> ~/.bashrc

# 重新加载
source ~/.bashrc
```

---

## 方案 B：使用 Git Bash

### 步骤 1：打开 Git Bash

在项目目录右键 → "Git Bash Here"

或者：
```bash
# 在 Git Bash 中
cd /c/Users/Administrator/Downloads/mnemon
```

### 步骤 2：手动配置（Git Bash 可能没有 sshpass）

由于 Git Bash 对 sshpass 支持有限，我们使用手动配置：

```bash
# 创建配置目录
mkdir -p ~/.mnemon

# 创建配置文件
cat > ~/.mnemon/remote.conf << 'EOF'
# Mnemon Remote Database Configuration
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PASSWORD=js20220113
export MNEMON_REMOTE_PORT=22
EOF

# 设置文件权限
chmod 600 ~/.mnemon/remote.conf
```

### 步骤 3：安装 sshpass（如果可能）

```bash
# Git Bash 可能需要手动安装 sshpass
# 如果无法安装，建议使用 WSL 方案
```

**注意：** 如果 Git Bash 无法安装 sshpass，强烈建议使用 WSL 方案。

---

## 验证清单（Windows）

### ✅ 基本验证

```bash
# 1. 检查环境变量
echo $MNEMON_REMOTE_HOST
echo $MNEMON_REMOTE_USER

# 2. 测试 SSH 连接（手动）
ssh agentdoc@192.168.180.127
# 输入密码：js20220113
# 如果能登录，说明网络连接正常
exit

# 3. 测试 mnemon 远程模式
mnemon status
```

### ✅ 功能验证

```bash
# 创建测试记忆
mnemon remember "Windows 环境测试成功" --cat general --imp 4 --tags "windows,test"

# 查询记忆
mnemon recall "Windows"

# 查看详细状态
mnemon status
```

### ✅ 数据一致性验证

```bash
# 在远程服务器验证
ssh agentdoc@192.168.180.127
mnemon recall "Windows"
# 应该能看到刚才创建的记忆
exit
```

---

## Windows 特定问题

### 问题 1：路径格式错误

**错误：** `No such file or directory`

**解决：**
```bash
# WSL 中访问 Windows 文件
cd /mnt/c/Users/Administrator/Downloads/mnemon

# Git Bash 中访问
cd /c/Users/Administrator/Downloads/mnemon
```

### 问题 2：sshpass 未找到

**错误：** `sshpass: command not found`

**解决：**
```bash
# 方案 1：使用 WSL
wsl
sudo apt-get install sshpass

# 方案 2：如果在 Git Bash，切换到 WSL
```

### 问题 3：权限问题

**错误：** `Permission denied`

**解决：**
```bash
# 检查配置文件权限
ls -la ~/.mnemon/remote.conf

# 设置正确权限
chmod 600 ~/.mnemon/remote.conf
```

### 问题 4：换行符问题

**错误：** 脚本执行出错

**解决：**
```bash
# 转换换行符（如果需要）
dos2unix scripts/setup_remote.sh

# 或者在 Git Bash 中
sed -i 's/\r$//' scripts/setup_remote.sh
```

---

## 快速命令参考（Windows）

### 启动 WSL 并加载配置
```bash
# 在 PowerShell 或 CMD 中
wsl
source ~/.mnemon/remote.conf
```

### 常用操作
```bash
# 创建记忆
mnemon remember "内容" --cat decision --imp 5

# 查询记忆
mnemon recall "关键词"

# 查看状态
mnemon status

# 切换到本地模式
unset MNEMON_REMOTE_HOST

# 切换回远程模式
source ~/.mnemon/remote.conf
```

---

## 推荐工作流程（Windows）

### 日常使用

1. **打开 WSL**
   ```bash
   wsl
   ```

2. **自动加载配置**（如果已添加到 ~/.bashrc）
   ```bash
   # 配置会自动加载
   ```

3. **使用 mnemon**
   ```bash
   mnemon remember "今天的决策" --cat decision --imp 4
   mnemon recall "决策"
   ```

### 多终端使用

每个新的 WSL 终端都需要加载配置：
```bash
source ~/.mnemon/remote.conf
```

或者添加到 `~/.bashrc` 实现自动加载：
```bash
echo "source ~/.mnemon/remote.conf" >> ~/.bashrc
```

---

## 完整执行步骤（Windows + WSL）

### 第一次配置

```bash
# 1. 打开 PowerShell 或 CMD
wsl

# 2. 进入项目目录
cd /mnt/c/Users/Administrator/Downloads/mnemon

# 3. 确认分支
git branch

# 4. 安装 sshpass
sudo apt-get update && sudo apt-get install -y sshpass

# 5. 运行配置脚本
bash scripts/setup_remote.sh
# 输入：192.168.180.127, agentdoc, js20220113, 22

# 6. 加载配置
source ~/.mnemon/remote.conf

# 7. 测试
mnemon status
mnemon remember "测试" --cat general --imp 3
mnemon recall "测试"

# 8. 永久配置
echo "source ~/.mnemon/remote.conf" >> ~/.bashrc
```

### 后续使用

```bash
# 打开 WSL（配置会自动加载）
wsl

# 直接使用
mnemon remember "内容" --cat decision --imp 5
mnemon recall "关键词"
```

---

## 性能提示（Windows）

- ✅ WSL 2 性能优于 WSL 1
- ✅ 将项目放在 WSL 文件系统中（`~/projects/`）比访问 Windows 文件系统（`/mnt/c/`）更快
- ✅ 使用 Windows Terminal 获得更好的体验

---

## 下一步

1. ✅ 按照上述步骤完成配置
2. ✅ 参考 `EXECUTION_CHECKLIST.md` 进行完整验证
3. ✅ 查看 `SETUP_GUIDE.md` 了解更多细节

---

## 获取帮助

- 完整指南：`SETUP_GUIDE.md`
- 执行清单：`EXECUTION_CHECKLIST.md`
- 快速参考：`QUICKSTART.md`

**Windows 用户推荐使用 WSL 方案以获得最佳体验！** 🪟✨
