# Windows 原生环境配置指南（SSH 密钥方案）

## ✅ 代码已更新

我已经修改了代码，移除了 sshpass 依赖，现在使用 SSH 密钥认证，完全支持 Windows 原生环境！

---

## 🚀 快速开始（Windows 原生）

### 第一步：生成 SSH 密钥对

在 PowerShell 或 Git Bash 中执行：

```powershell
# 生成 SSH 密钥对
ssh-keygen -t rsa -b 4096 -C "mnemon-remote"

# 提示信息：
# Enter file in which to save the key: 直接回车（使用默认位置）
# Enter passphrase: 直接回车（不设置密码，方便自动化）
# Enter same passphrase again: 直接回车
```

**生成的文件：**
- 私钥：`C:\Users\Administrator\.ssh\id_rsa`
- 公钥：`C:\Users\Administrator\.ssh\id_rsa.pub`

### 第二步：复制公钥到远程服务器

**方式 A：使用 PowerShell**

```powershell
# 1. 查看公钥内容
type $env:USERPROFILE\.ssh\id_rsa.pub

# 2. 复制输出的内容（Ctrl+C）

# 3. SSH 登录到远程服务器
ssh agentdoc@192.168.180.127
# 输入密码：js20220113

# 4. 在远程服务器上添加公钥
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "粘贴你的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

**方式 B：使用一行命令（如果有 ssh-copy-id）**

```bash
# Git Bash 中
ssh-copy-id agentdoc@192.168.180.127
# 输入密码：js20220113
```

### 第三步：测试 SSH 密钥登录

```powershell
# 测试无密码登录
ssh agentdoc@192.168.180.127

# 如果能直接登录（不需要输入密码），说明配置成功！
exit
```

### 第四步：配置 Mnemon 远程模式

在 PowerShell 中：

```powershell
# 设置环境变量（当前会话）
$env:MNEMON_REMOTE_HOST="192.168.180.127"
$env:MNEMON_REMOTE_USER="agentdoc"
$env:MNEMON_REMOTE_PORT="22"

# 注意：不需要设置 MNEMON_REMOTE_PASSWORD，使用 SSH 密钥认证
```

**永久配置（可选）：**

创建 PowerShell 配置文件：

```powershell
# 创建或编辑 PowerShell 配置文件
notepad $PROFILE

# 添加以下内容：
$env:MNEMON_REMOTE_HOST="192.168.180.127"
$env:MNEMON_REMOTE_USER="agentdoc"
$env:MNEMON_REMOTE_PORT="22"

# 保存并关闭
```

### 第五步：测试 Mnemon 远程模式

```powershell
# 进入项目目录
cd C:\Users\Administrator\Downloads\mnemon

# 测试远程连接
mnemon status

# 创建测试记忆
mnemon remember "Windows 原生环境测试" --cat general --imp 3

# 查询记忆
mnemon recall "Windows"
```

---

## 📋 完整执行清单

### ✅ 步骤 1：生成 SSH 密钥

```powershell
ssh-keygen -t rsa -b 4096 -C "mnemon-remote"
# 全部直接回车（使用默认设置，不设置密码）
```

### ✅ 步骤 2：查看公钥

```powershell
type $env:USERPROFILE\.ssh\id_rsa.pub
```

复制输出的内容（整行，从 `ssh-rsa` 开始到结尾）

### ✅ 步骤 3：添加公钥到远程服务器

```powershell
# SSH 登录
ssh agentdoc@192.168.180.127
# 密码：js20220113

# 在远程服务器上执行：
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "你复制的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

### ✅ 步骤 4：测试密钥登录

```powershell
ssh agentdoc@192.168.180.127
# 应该不需要密码直接登录
exit
```

### ✅ 步骤 5：配置环境变量

```powershell
$env:MNEMON_REMOTE_HOST="192.168.180.127"
$env:MNEMON_REMOTE_USER="agentdoc"
$env:MNEMON_REMOTE_PORT="22"
```

### ✅ 步骤 6：测试 Mnemon

```powershell
cd C:\Users\Administrator\Downloads\mnemon
mnemon status
mnemon remember "测试" --cat general --imp 3
mnemon recall "测试"
```

---

## 🎯 验证成功标志

- ✅ SSH 密钥已生成（`~/.ssh/id_rsa` 和 `~/.ssh/id_rsa.pub`）
- ✅ 公钥已添加到远程服务器（`~/.ssh/authorized_keys`）
- ✅ SSH 无密码登录成功
- ✅ 环境变量已设置
- ✅ `mnemon status` 显示远程数据库信息
- ✅ 能创建和查询记忆

---

## 🐛 故障排除

### 问题 1：SSH 密钥登录失败

**症状：** 仍然提示输入密码

**解决：**
```powershell
# 检查公钥是否正确添加
ssh agentdoc@192.168.180.127 "cat ~/.ssh/authorized_keys"

# 检查权限
ssh agentdoc@192.168.180.127 "ls -la ~/.ssh/"

# 确保权限正确：
# ~/.ssh 应该是 700
# ~/.ssh/authorized_keys 应该是 600
```

### 问题 2：mnemon 找不到 ssh 命令

**症状：** `exec: "ssh": executable file not found in %PATH%`

**解决：**
```powershell
# 检查 SSH 是否在 PATH 中
where.exe ssh

# 如果没有，安装 OpenSSH 客户端
# Windows 10/11 自带，可能需要启用：
# 设置 -> 应用 -> 可选功能 -> 添加功能 -> OpenSSH 客户端
```

### 问题 3：环境变量未生效

**症状：** mnemon 仍然使用本地数据库

**解决：**
```powershell
# 检查环境变量
echo $env:MNEMON_REMOTE_HOST
echo $env:MNEMON_REMOTE_USER

# 如果为空，重新设置
$env:MNEMON_REMOTE_HOST="192.168.180.127"
$env:MNEMON_REMOTE_USER="agentdoc"
```

### 问题 4：权限被拒绝

**症状：** `Permission denied (publickey)`

**解决：**
```powershell
# 检查私钥权限（Windows 上通常不是问题）
# 确保公钥正确添加到远程服务器

# 重新添加公钥
ssh agentdoc@192.168.180.127
# 输入密码
cat >> ~/.ssh/authorized_keys << 'EOF'
你的公钥内容
EOF
chmod 600 ~/.ssh/authorized_keys
exit
```

---

## 💡 使用技巧

### 快速启动脚本

创建 `start_mnemon.ps1`：

```powershell
# start_mnemon.ps1
$env:MNEMON_REMOTE_HOST="192.168.180.127"
$env:MNEMON_REMOTE_USER="agentdoc"
$env:MNEMON_REMOTE_PORT="22"

Write-Host "Mnemon 远程模式已启用" -ForegroundColor Green
Write-Host "远程主机: $env:MNEMON_REMOTE_HOST" -ForegroundColor Cyan
Write-Host ""
Write-Host "测试连接..."
mnemon status
```

使用：
```powershell
.\start_mnemon.ps1
```

### 切换本地/远程模式

```powershell
# 切换到远程模式
$env:MNEMON_REMOTE_HOST="192.168.180.127"
$env:MNEMON_REMOTE_USER="agentdoc"

# 切换到本地模式
Remove-Item Env:\MNEMON_REMOTE_HOST
Remove-Item Env:\MNEMON_REMOTE_USER
```

---

## 📚 相关文档

- `EXECUTION_CHECKLIST.md` - 完整验证清单
- `SETUP_GUIDE.md` - 详细配置指南
- `WINDOWS_NATIVE.md` - Windows 原生方案说明

---

## 🎉 完成！

现在您可以在 Windows 原生环境下使用 Mnemon 远程数据库功能了！

**下一步：**
1. 按照上述步骤配置 SSH 密钥
2. 测试远程连接
3. 开始使用集中式 AI 记忆管理

**享受使用！** 🚀
