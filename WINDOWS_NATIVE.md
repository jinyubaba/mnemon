# Windows 原生环境配置指南（无需 WSL）

## 🪟 Windows 原生方案

本指南适用于在 Windows 原生环境（PowerShell/CMD/Git Bash）下使用，无需 WSL。

---

## ✅ 配置完成

远程数据库功能已经成功配置并测试通过！

**当前状态：**
- ✅ SSH 密钥认证已配置
- ✅ 远程服务器已安装 mnemon
- ✅ 本地 Windows 机器已安装 mnemon
- ✅ 远程命令执行测试通过

**实现方案：** 使用 SSH 密钥认证，无需 sshpass，完全支持 Windows 原生环境。

---

## 🚀 快速开始

### 1. 设置环境变量

每次使用前，需要设置环境变量（或使用提供的脚本）：

```bash
# 方式 A：手动设置
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PORT=22
export PATH=$PATH:/c/Users/Administrator/go/bin

# 方式 B：使用脚本（推荐）
source scripts/setup_remote_env.sh
```

### 2. 使用 mnemon

```bash
# 添加记忆
mnemon remember "这是一条测试记忆" --cat fact --imp 5

# 查询记忆
mnemon recall "测试"

# 查看状态
mnemon status
```

所有命令都会自动在远程服务器上执行，数据存储在远程服务器的 `~/.mnemon` 目录。

---

## 📋 配置详情

### SSH 密钥认证（已完成）

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

## 📝 技术实现

### 代码修改

为了支持 Windows 原生环境，我们做了以下修改：

1. **移除 sshpass 依赖**
   - 修改 `internal/remote/execute.go`
   - 使用原生 SSH 客户端 + 密钥认证
   - 不再需要密码

2. **添加 PATH 设置**
   - 在远程命令执行前自动设置 PATH
   - 确保远程服务器能找到 mnemon 命令

3. **修复 import 问题**
   - 修复 `cmd/remote_helper.go` 中的类型定义
   - 使用 `pflag.Flag` 而不是 `cobra.Flag`

### 工作原理

```
本地 Windows 机器                远程 Ubuntu 服务器
     |                                |
     | 1. 检测环境变量                |
     |    MNEMON_REMOTE_HOST          |
     |                                |
     | 2. 通过 SSH 连接               |
     |---------------------------->   |
     |    (使用 SSH 密钥认证)         |
     |                                |
     | 3. 执行 mnemon 命令            |
     |    export PATH=... && mnemon   |
     |                           ---> | 4. 执行命令
     |                                | 5. 操作数据库
     |                                |    ~/.mnemon/
     |                                |
     | 6. 返回结果                    |
     | <----------------------------- |
     |                                |
```

---

## 🎯 测试结果

已完成的测试：

✅ SSH 密钥认证成功
✅ 远程 mnemon 命令执行成功
✅ `mnemon remember` 命令测试通过
✅ `mnemon recall` 命令测试通过

测试示例：
```bash
# 测试 1：添加记忆
$ mnemon remember "这是第一条测试记忆" --cat fact --imp 5
{
  "action": "added",
  "id": "26a622f3-2750-4f2c-ae92-4c536dcb74a2",
  ...
}

# 测试 2：查询记忆
$ mnemon recall "测试"
{
  "results": [
    {
      "insight": {
        "content": "这是第一条测试记忆",
        ...
      },
      "score": 0.45
    }
  ]
}
```

---

## ❌ 已解决的问题

### 问题 1：sshpass 不可用
**原因：** sshpass 是 Linux 工具，Windows 原生不支持
**解决：** 使用 SSH 密钥认证，不需要 sshpass

### 问题 2：远程服务器找不到 mnemon
**原因：** SSH 非交互式 shell 不加载 ~/.bashrc
**解决：** 在远程命令中添加 `export PATH=$PATH:$HOME/go/bin`

### 问题 3：编译错误
**原因：**
- `execute.go` 缺少 package 声明和 import
- `ssh.go` 有未使用的 import
- `remote_helper.go` 使用了错误的类型 `cobra.Flag`

**解决：**
- 添加正确的 package 和 import 语句
- 删除未使用的 import
- 使用 `pflag.Flag` 替代 `cobra.Flag`

---

## 📚 相关文档

- `REMOTE_SETUP_COMPLETE.md` - 配置完成说明
- `WINDOWS_SSH_KEY_SETUP.md` - SSH 密钥配置详细步骤
- `scripts/setup_remote_env.sh` - 环境变量设置脚本

---

## 💡 下一步

现在你可以：

1. **正常使用 mnemon**
   - 所有数据自动存储在远程服务器
   - 无需手动同步

2. **集成到其他工具**
   - Claude Code
   - OpenClaw
   - NanoClaw

3. **扩展功能**
   - 添加更多远程服务器
   - 配置多个命名存储（stores）

---

## 🔧 故障排除

### 问题：SSH 连接失败
```bash
# 测试 SSH 连接
ssh -o BatchMode=yes agentdoc@192.168.180.127 "echo 'SSH OK'"

# 如果失败，检查：
# 1. SSH 密钥是否正确配置
# 2. 远程服务器是否可访问
# 3. 防火墙设置
```

### 问题：mnemon 命令找不到
```bash
# 检查本地 PATH
echo $PATH | grep "go/bin"

# 如果没有，添加到 PATH
export PATH=$PATH:/c/Users/Administrator/go/bin

# 或使用完整路径
/c/Users/Administrator/go/bin/mnemon --version
```

### 问题：环境变量未设置
```bash
# 检查环境变量
echo $MNEMON_REMOTE_HOST

# 如果为空，使用脚本设置
source scripts/setup_remote_env.sh
```

---

## 📝 当前状态

- ✅ 远程数据库功能已实现（remote-db 分支）
- ✅ 完整的文档和配置脚本
- ✅ 使用 SSH 密钥认证（无需 sshpass）
- ✅ Windows 原生环境完全支持
- ✅ 测试通过，可以正常使用
