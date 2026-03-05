# Mnemon 远程数据库配置指南

本指南将帮助您配置 Mnemon 的远程数据库功能，使用您的 Ubuntu 服务器 (192.168.180.127) 作为数据库托管服务器。

## 📋 前置要求

- 远程服务器：Ubuntu (192.168.180.127)
  - 用户名：agentdoc
  - 密码：js20220113
  - SSH 端口：22
- 本地机器：Windows/Linux/macOS
- Go 1.24+ (两端都需要)

---

## 第一部分：远程服务器配置

### 步骤 1：登录远程服务器

```bash
ssh agentdoc@192.168.180.127
```

输入密码：`js20220113`

### 步骤 2：检查 Go 环境

```bash
# 检查 Go 是否已安装
go version

# 如果未安装，请先安装 Go 1.24+
# Ubuntu 安装示例：
wget https://go.dev/dl/go1.24.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
```

### 步骤 3：在远程服务器上安装 Mnemon

**方式 A：从源码安装（推荐，使用 remote-db 分支）**

```bash
# 克隆仓库
cd ~
git clone https://github.com/mnemon-dev/mnemon.git
cd mnemon

# 切换到 remote-db 分支
git checkout remote-db

# 构建并安装
make install

# 验证安装
mnemon --version
which mnemon
```

**方式 B：使用 go install（如果 remote-db 分支已合并到主分支）**

```bash
go install github.com/mnemon-dev/mnemon@latest
mnemon --version
```

### 步骤 4：初始化远程数据库

```bash
# 创建数据目录
mkdir -p ~/.mnemon/data/default

# 测试 mnemon 是否正常工作
mnemon status

# 应该看到类似输出：
# {
#   "total_insights": 0,
#   "deleted_insights": 0,
#   ...
# }
```

### 步骤 5：（可选）创建测试数据

```bash
# 在远程服务器上创建一些测试数据
mnemon remember "这是远程服务器上的测试记忆" --cat general --imp 3
mnemon remember "远程数据库配置成功" --cat fact --imp 5

# 查看状态
mnemon status

# 查询测试数据
mnemon recall "测试"
```

### 步骤 6：保持 SSH 连接或退出

```bash
# 如果配置完成，可以退出
exit
```

**✅ 远程服务器配置完成！**

---

## 第二部分：本地机器配置

### 步骤 1：安装 sshpass

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install sshpass
```

**Windows (使用 WSL):**
```bash
# 打开 WSL (Ubuntu)
wsl

# 安装 sshpass
sudo apt-get update
sudo apt-get install sshpass
```

**Windows (使用 Git Bash):**
```bash
# Git Bash 可能需要手动安装 sshpass
# 或者使用 WSL 代替
```

**macOS:**
```bash
brew install sshpass
```

验证安装：
```bash
sshpass -V
# 应该显示版本信息
```

### 步骤 2：切换到 remote-db 分支

```bash
cd C:\Users\Administrator\Downloads\mnemon

# 确认当前在 remote-db 分支
git branch
# 应该显示 * remote-db

# 如果不在，切换到该分支
git checkout remote-db
```

### 步骤 3：配置远程连接

**方式 A：使用配置脚本（推荐）**

```bash
# 在 Git Bash 或 WSL 中运行
bash scripts/setup_remote.sh
```

脚本会提示输入：
- Remote host: `192.168.180.127`
- Remote user: `agentdoc`
- Remote password: `js20220113`
- Remote port: `22` (直接回车使用默认值)

脚本会自动：
1. 测试 SSH 连接
2. 检查远程服务器上的 mnemon 安装
3. 创建配置文件 `~/.mnemon/remote.conf`

**方式 B：手动配置环境变量**

```bash
# 创建配置文件
mkdir -p ~/.mnemon
cat > ~/.mnemon/remote.conf << 'EOF'
# Mnemon Remote Database Configuration
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PASSWORD=js20220113
export MNEMON_REMOTE_PORT=22
EOF

# 设置文件权限（仅所有者可读写）
chmod 600 ~/.mnemon/remote.conf
```

### 步骤 4：加载配置

```bash
# 加载配置文件
source ~/.mnemon/remote.conf

# 验证环境变量
echo $MNEMON_REMOTE_HOST
# 应该输出：192.168.180.127
```

**（可选）永久加载配置**

```bash
# 添加到 shell 配置文件
echo "source ~/.mnemon/remote.conf" >> ~/.bashrc  # 或 ~/.zshrc

# 重新加载配置
source ~/.bashrc  # 或 source ~/.zshrc
```

**✅ 本地机器配置完成！**

---

## 第三部分：功能验证

### 验证 1：测试连接

```bash
# 测试远程连接和 mnemon 状态
mnemon status
```

**预期输出：**
```json
{
  "total_insights": 2,
  "deleted_insights": 0,
  "by_category": {
    "fact": 1,
    "general": 1
  },
  ...
}
```

如果看到远程服务器上的数据（步骤 5 创建的测试数据），说明连接成功！

### 验证 2：创建新记忆

```bash
# 从本地创建记忆，存储到远程服务器
mnemon remember "本地客户端创建的记忆" --cat decision --imp 4 --tags "测试,远程"
```

**预期输出：**
```json
{
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "content": "本地客户端创建的记忆",
  "category": "decision",
  "importance": 4,
  "action": "added",
  ...
}
```

### 验证 3：查询记忆

```bash
# 查询刚才创建的记忆
mnemon recall "本地客户端"
```

**预期输出：**
应该能看到刚才创建的记忆。

### 验证 4：查看所有记忆

```bash
# 查询所有记忆
mnemon recall "记忆" --limit 20
```

应该能看到：
- 远程服务器上创建的测试数据
- 本地客户端创建的新记忆

### 验证 5：测试其他命令

```bash
# 测试 link 命令（需要两个有效的 ID）
# 先获取两个 ID
mnemon recall "记忆" --limit 2
# 复制两个 ID，然后：
mnemon link <id1> <id2> --type semantic --weight 0.8

# 测试 forget 命令
mnemon forget <某个id>

# 再次查看状态
mnemon status
```

---

## 第四部分：验证数据一致性

### 在远程服务器上验证

```bash
# SSH 到远程服务器
ssh agentdoc@192.168.180.127

# 查看数据库状态
mnemon status

# 查询记忆
mnemon recall "本地客户端"

# 应该能看到从本地客户端创建的记忆
```

### 数据同步验证

1. **本地创建 → 远程查看**
   ```bash
   # 本地：
   mnemon remember "同步测试A" --cat general --imp 3

   # 远程：
   ssh agentdoc@192.168.180.127
   mnemon recall "同步测试A"
   # 应该能找到
   ```

2. **远程创建 → 本地查看**
   ```bash
   # 远程：
   ssh agentdoc@192.168.180.127
   mnemon remember "同步测试B" --cat general --imp 3
   exit

   # 本地：
   mnemon recall "同步测试B"
   # 应该能找到
   ```

---

## 第五部分：故障排除

### 问题 1：sshpass 未找到

**错误信息：**
```
ssh execution failed: exec: "sshpass": executable file not found in $PATH
```

**解决方案：**
```bash
# Ubuntu/Debian
sudo apt-get install sshpass

# macOS
brew install sshpass

# Windows: 使用 WSL
```

### 问题 2：SSH 连接失败

**错误信息：**
```
ssh execution failed: ... Connection refused
```

**检查步骤：**
```bash
# 1. 测试基本 SSH 连接
ssh agentdoc@192.168.180.127

# 2. 检查防火墙
# 在远程服务器上：
sudo ufw status
sudo ufw allow 22/tcp

# 3. 检查 SSH 服务
sudo systemctl status ssh
```

### 问题 3：远程 mnemon 未找到

**错误信息：**
```
bash: mnemon: command not found
```

**解决方案：**
```bash
# SSH 到远程服务器
ssh agentdoc@192.168.180.127

# 检查 mnemon 位置
which mnemon
echo $PATH

# 如果不在 PATH 中，添加到 PATH
echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc

# 重新安装 mnemon
cd ~/mnemon
make install
```

### 问题 4：权限被拒绝

**错误信息：**
```
Permission denied (publickey,password)
```

**解决方案：**
```bash
# 检查密码是否正确
ssh agentdoc@192.168.180.127
# 手动输入密码测试

# 检查环境变量
echo $MNEMON_REMOTE_PASSWORD

# 重新设置环境变量
export MNEMON_REMOTE_PASSWORD=js20220113
```

### 问题 5：本地模式和远程模式切换

**切换到本地模式：**
```bash
# 临时禁用远程模式
unset MNEMON_REMOTE_HOST
unset MNEMON_REMOTE_USER
unset MNEMON_REMOTE_PASSWORD
unset MNEMON_REMOTE_PORT

# 现在 mnemon 命令会使用本地数据库
mnemon status
```

**切换回远程模式：**
```bash
# 重新加载配置
source ~/.mnemon/remote.conf

# 现在 mnemon 命令会使用远程数据库
mnemon status
```

---

## 第六部分：性能测试

### 测试响应时间

```bash
# 测试 status 命令
time mnemon status

# 测试 remember 命令
time mnemon remember "性能测试" --cat general --imp 3

# 测试 recall 命令
time mnemon recall "性能"
```

### 批量操作测试

```bash
# 创建多条记忆
for i in {1..10}; do
  mnemon remember "批量测试记忆 $i" --cat general --imp 3
done

# 查看状态
mnemon status
```

---

## 第七部分：日常使用

### 启动新会话

```bash
# 每次打开新终端时
source ~/.mnemon/remote.conf

# 或者已添加到 ~/.bashrc，则自动加载
```

### 常用命令

```bash
# 创建记忆
mnemon remember "内容" --cat decision --imp 5

# 查询记忆
mnemon recall "关键词"

# 查看状态
mnemon status

# 查看日志
mnemon log --limit 20

# 垃圾回收
mnemon gc --dry-run
```

---

## 📊 验证清单

完成以下检查项以确保配置成功：

- [ ] 远程服务器上 Go 已安装
- [ ] 远程服务器上 mnemon 已安装并可运行
- [ ] 本地机器上 sshpass 已安装
- [ ] 本地机器上环境变量已配置
- [ ] `mnemon status` 能显示远程数据库状态
- [ ] 本地创建的记忆能在远程服务器上查看
- [ ] 远程创建的记忆能在本地客户端查看
- [ ] 所有主要命令（remember, recall, link, forget）都能正常工作

---

## 🎉 完成！

如果所有验证步骤都通过，您的远程数据库配置已成功！现在您可以：

1. 在任何地方使用本地客户端访问远程数据库
2. 多个客户端共享同一个数据库
3. 集中管理所有 AI 代理的记忆

## 📚 更多信息

- 详细文档：`docs/REMOTE.md`
- 中文文档：`docs/zh/REMOTE.md`
- 分支说明：`REMOTE_BRANCH.md`
