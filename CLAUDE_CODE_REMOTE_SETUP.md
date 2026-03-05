# Claude Code 远程数据库配置指南

## 📋 概述

本指南说明如何在 Claude Code 中配置 mnemon 使用远程数据库。

## 🔧 配置步骤

### 1. 更新 Claude Code 设置

在项目的 `.claude/settings.local.json` 中添加环境变量配置：

```json
{
  "permissions": {
    "allow": [
      "Bash(go build -o mnemon.exe .)"
    ]
  },
  "env": {
    "MNEMON_REMOTE_HOST": "192.168.180.127",
    "MNEMON_REMOTE_USER": "agentdoc",
    "MNEMON_REMOTE_PORT": "22",
    "PATH": "${PATH}:/c/Users/Administrator/go/bin"
  }
}
```

### 2. 验证配置

在 Claude Code 中运行以下命令验证配置：

```bash
# 检查环境变量
echo $MNEMON_REMOTE_HOST

# 测试 mnemon 命令
mnemon status

# 测试远程连接
mnemon recall "test"
```

## 🚀 使用方式

配置完成后，Claude Code 会自动使用远程数据库：

### 自动记忆（通过 hooks）

如果你运行了 `mnemon setup`，Claude Code 会在以下时机自动调用 mnemon：

1. **Prime Hook**：会话开始时，自动 recall 相关记忆
2. **User Prompt Hook**：用户输入后，recall 相关上下文
3. **Stop Hook**：会话结束时，remember 重要内容

### 手动使用

你也可以在对话中直接要求 Claude 使用 mnemon：

```
"请记住：我喜欢使用 TypeScript 而不是 JavaScript"
"回忆一下我之前关于数据库设计的决定"
"查询我之前提到的所有关于性能优化的内容"
```

## 📝 工作原理

```
Claude Code (本地)
     |
     | 1. 检测到 MNEMON_REMOTE_HOST
     |
     | 2. 执行 mnemon 命令
     |    (自动通过 SSH 转发)
     |
     v
远程 Ubuntu 服务器
     |
     | 3. 在远程执行 mnemon
     |
     | 4. 操作远程数据库
     |    ~/.mnemon/data/default/
     |
     | 5. 返回结果
     |
     v
Claude Code (显示结果)
```

## ✅ 优势

1. **跨设备同步**：所有设备共享同一个记忆库
2. **持久化存储**：数据存储在专用服务器上，更安全
3. **无缝集成**：Claude Code 自动使用远程数据库
4. **透明操作**：使用体验与本地数据库完全相同

## 🔍 验证远程模式

检查 mnemon 是否在使用远程模式：

```bash
# 查看状态（会显示远程路径）
mnemon status

# 输出示例：
# {
#   "db_path": "/home/agentdoc/.mnemon/data/default/mnemon.db",
#   ...
# }
```

如果 `db_path` 显示的是远程服务器路径（`/home/agentdoc/...`），说明远程模式已启用。

## 🛠️ 故障排除

### 问题 1：Claude Code 找不到 mnemon

**解决方案**：确保 PATH 配置正确

```json
{
  "env": {
    "PATH": "${PATH}:/c/Users/Administrator/go/bin"
  }
}
```

### 问题 2：SSH 连接失败

**解决方案**：测试 SSH 连接

```bash
ssh -o BatchMode=yes agentdoc@192.168.180.127 "echo 'OK'"
```

如果失败，检查 SSH 密钥配置。

### 问题 3：环境变量未生效

**解决方案**：重启 Claude Code 或重新加载项目

## 📚 相关文档

- `REMOTE_SETUP_COMPLETE.md` - 远程数据库配置完成说明
- `WINDOWS_NATIVE.md` - Windows 原生环境配置
- `internal/setup/assets/claude/guide.md` - Claude Code 使用指南

## 💡 最佳实践

1. **定期备份**：虽然数据在远程服务器上，但仍建议定期备份
2. **网络稳定性**：确保本地机器与远程服务器之间网络稳定
3. **安全性**：定期更新 SSH 密钥，使用强密码保护服务器
4. **监控**：定期检查远程数据库大小和性能

## 🎯 下一步

配置完成后，你可以：

1. 正常使用 Claude Code，所有记忆自动存储到远程
2. 在其他设备上配置相同的远程连接，实现跨设备同步
3. 使用 `mnemon setup` 配置自动化 hooks
