# Windows 原生环境配置指南（无需 WSL）

## 🪟 Windows 原生方案

本指南适用于在 Windows 原生环境（PowerShell/CMD/Git Bash）下使用，无需 WSL。

---

## ⚠️ 重要说明

当前实现的远程模式依赖 `sshpass` 工具，这是一个 Linux 工具，在 Windows 原生环境下不可用。

**推荐方案：使用 SSH 密钥认证**

使用 SSH 密钥认证后，不需要 sshpass，可以在 Windows 原生环境下直接使用。

---

## 方案：SSH 密钥认证配置

### 第一步：生成 SSH 密钥对（如果还没有）

在 PowerShell 或 Git Bash 中：

```bash
# 生成 SSH 密钥对
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 按提示操作：
# - 保存位置：直接回车（使用默认 ~/.ssh/id_rsa）
# - 密码：直接回车（不设置密码，方便自动化）
```

### 第二步：将公钥复制到远程服务器

```bash
# 方式 A：使用 ssh-copy-id（如果可用）
ssh-copy-id agentdoc@192.168.180.127

# 方式 B：手动复制
# 1. 查看公钥内容
cat ~/.ssh/id_rsa.pub

# 2. SSH 登录到远程服务器
ssh agentdoc@192.168.180.127
# 输入密码：js20220113

# 3. 在远程服务器上添加公钥
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "你的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

### 第三步：测试 SSH 密钥登录

```bash
# 测试无密码登录
ssh agentdoc@192.168.180.127

# 如果能直接登录（不需要输入密码），说明配置成功
exit
```

---

## ❌ 当前限制

由于当前实现依赖 `sshpass`，在 Windows 原生环境下有以下限制：

1. **无法使用密码认证的远程模式**
   - `sshpass` 是 Linux 工具，Windows 原生不支持

2. **需要修改代码以支持 Windows 原生**
   - 方案 A：使用 SSH 密钥认证（推荐）
   - 方案 B：使用 Go 的 SSH 库重写远程执行部分

---

## 🔧 临时解决方案

### 方案 1：使用 SSH 密钥 + 修改代码

修改 `internal/remote/execute.go`，移除 sshpass 依赖：

```go
// 修改前（使用 sshpass）
sshArgs := []string{
    "-p", cfg.Password,
    "ssh",
    "-o", "StrictHostKeyChecking=no",
    ...
}
cmd := exec.Command("sshpass", sshArgs...)

// 修改后（使用 SSH 密钥）
sshArgs := []string{
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-p", cfg.Port,
    fmt.Sprintf("%s@%s", cfg.User, cfg.Host),
    remoteCmd,
}
cmd := exec.Command("ssh", sshArgs...)
```

### 方案 2：使用 WSL（推荐）

虽然您不想使用 WSL，但这是目前最简单的方案：

```powershell
# 安装 WSL（一次性操作）
wsl --install

# 使用 WSL 运行 mnemon
wsl bash scripts/windows_setup.sh
```

### 方案 3：等待代码改进

我可以帮您修改代码，使用 Go 的 SSH 库（`golang.org/x/crypto/ssh`）重写远程执行部分，这样就完全不依赖外部工具了。

---

## 🚀 推荐行动方案

### 立即可用：配置 SSH 密钥

1. **生成密钥对**
   ```bash
   ssh-keygen -t rsa -b 4096
   ```

2. **复制公钥到远程服务器**
   ```bash
   # 查看公钥
   type %USERPROFILE%\.ssh\id_rsa.pub

   # 手动复制到远程服务器的 ~/.ssh/authorized_keys
   ```

3. **测试连接**
   ```bash
   ssh agentdoc@192.168.180.127
   ```

4. **修改代码移除 sshpass 依赖**
   - 我可以帮您修改 `internal/remote/execute.go`
   - 移除 sshpass，直接使用 ssh 命令

### 长期方案：重写远程执行

使用 Go 的原生 SSH 库重写，完全不依赖外部命令：

```go
import "golang.org/x/crypto/ssh"

// 使用 Go SSH 库连接和执行命令
// 支持密码和密钥两种认证方式
// 完全跨平台，Windows/Linux/macOS 都可用
```

---

## 💡 我可以帮您做什么？

### 选项 1：修改现有代码支持 SSH 密钥

我可以修改 `internal/remote/execute.go`，移除 sshpass 依赖，改用 SSH 密钥认证。

**优点：**
- 快速实现
- 不需要额外依赖
- Windows 原生支持

**缺点：**
- 需要配置 SSH 密钥
- 不支持密码认证

### 选项 2：使用 Go SSH 库重写

我可以使用 `golang.org/x/crypto/ssh` 重写远程执行部分。

**优点：**
- 完全跨平台
- 支持密码和密钥两种认证
- 不依赖外部工具
- 更好的错误处理

**缺点：**
- 需要更多代码改动
- 需要添加新的依赖

### 选项 3：提供 Windows 批处理脚本

创建 Windows 批处理脚本，使用 Windows 原生 SSH 客户端。

---

## 🎯 建议

**最佳方案：选项 2（使用 Go SSH 库重写）**

这是最彻底的解决方案，可以：
- ✅ 完全跨平台（Windows/Linux/macOS）
- ✅ 支持密码和密钥认证
- ✅ 不依赖任何外部工具
- ✅ 更好的错误处理和用户体验

**快速方案：选项 1（SSH 密钥 + 修改代码）**

如果您急需使用，可以：
1. 配置 SSH 密钥（5 分钟）
2. 我修改代码移除 sshpass（5 分钟）
3. 立即可用

---

## ❓ 您的选择

请告诉我您希望采用哪个方案：

1. **配置 SSH 密钥 + 修改代码移除 sshpass**（快速）
2. **使用 Go SSH 库重写远程执行**（彻底）
3. **使用 WSL**（最简单，但您不想用）
4. **其他方案**

我会根据您的选择提供相应的实现。

---

## 📝 当前状态

- ✅ 远程数据库功能已实现（remote-db 分支）
- ✅ 完整的文档和配置脚本
- ⚠️ 依赖 sshpass（Linux 工具）
- ❌ Windows 原生环境暂不可用

**需要：** 修改代码以支持 Windows 原生环境
