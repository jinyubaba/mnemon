# Mnemon 远程数据库团队部署指南

## 📋 概述

本指南说明如何在团队中部署和使用 mnemon 远程数据库，让所有团队成员共享同一个知识库。

## 🎯 部署架构

```
团队成员 A (Windows)          团队成员 B (Mac)          团队成员 C (Linux)
     |                              |                            |
     |                              |                            |
     +------------------------------+----------------------------+
                                    |
                              SSH 密钥认证
                                    |
                                    v
                          远程 Ubuntu 服务器
                        (192.168.180.127)
                                    |
                              mnemon 数据库
                        ~/.mnemon/data/default/
```

## 🚀 快速开始（新成员加入）

### 前提条件

1. 远程服务器已配置（本指南假设已完成）
2. 新成员有服务器访问权限
3. 新成员机器上已安装 Go 1.24+

### 步骤 1：安装 mnemon

**在新成员的机器上：**

```bash
# 克隆仓库
git clone https://github.com/jinyubaba/mnemon.git
cd mnemon

# 切换到 remote-db 分支
git checkout remote-db

# 编译并安装
make install

# 验证安装
mnemon --version
```

### 步骤 2：配置 SSH 密钥

**生成 SSH 密钥对：**

```bash
# 生成密钥（如果还没有）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 查看公钥
cat ~/.ssh/id_rsa.pub
```

**将公钥发送给管理员：**

新成员需要将公钥内容发送给服务器管理员，管理员将其添加到服务器的 `~/.ssh/authorized_keys`。

**管理员操作（在远程服务器上）：**

```bash
# 登录到远程服务器
ssh agentdoc@192.168.180.127

# 添加新成员的公钥
echo "新成员的公钥内容" >> ~/.ssh/authorized_keys

# 确保权限正确
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### 步骤 3：配置环境变量

**方式 A：使用配置脚本（推荐）**

```bash
# 使用项目提供的脚本
source scripts/setup_remote_env.sh
```

**方式 B：手动配置**

在 `~/.bashrc` 或 `~/.zshrc` 中添加：

```bash
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PORT=22
export PATH=$PATH:$HOME/go/bin  # 或 Windows: /c/Users/YourName/go/bin
```

然后重新加载配置：

```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

### 步骤 4：测试连接

```bash
# 测试 SSH 连接
ssh -o BatchMode=yes agentdoc@192.168.180.127 "echo 'SSH OK'"

# 测试 mnemon
mnemon status

# 添加一条测试记忆
mnemon remember "我是团队成员 [你的名字]，已成功连接到远程数据库" --cat fact --imp 3
```

## 🔐 安全最佳实践

### 1. SSH 密钥管理

- ✅ **使用强密钥**：至少 4096 位 RSA 密钥
- ✅ **保护私钥**：设置密钥密码（可选但推荐）
- ✅ **定期轮换**：每 6-12 个月更新密钥
- ❌ **不要共享私钥**：每个成员使用自己的密钥对

### 2. 访问控制

```bash
# 管理员：定期审查授权密钥
ssh agentdoc@192.168.180.127
cat ~/.ssh/authorized_keys

# 移除离职成员的密钥
# 编辑 ~/.ssh/authorized_keys，删除对应行
```

### 3. 数据备份

```bash
# 管理员：定期备份数据库
ssh agentdoc@192.168.180.127
cd ~/.mnemon/data/default/
tar -czf mnemon-backup-$(date +%Y%m%d).tar.gz mnemon.db

# 下载备份到本地
scp agentdoc@192.168.180.127:~/.mnemon/data/default/mnemon-backup-*.tar.gz ./backups/
```

## 👥 团队协作指南

### 记忆分类约定

建议团队统一使用以下分类：

| 类别 | 用途 | 重要性建议 |
|------|------|-----------|
| `preference` | 团队偏好、工具选择 | 3-4 |
| `decision` | 架构决策、技术选型 | 4-5 |
| `fact` | 项目事实、配置信息 | 3-5 |
| `insight` | 经验总结、最佳实践 | 3-4 |
| `context` | 项目背景、业务逻辑 | 2-4 |

### 标签约定

使用统一的标签体系：

```bash
# 项目相关
--tags "项目名,模块名"

# 技术栈
--tags "技术栈,语言/框架"

# 团队成员
--tags "负责人,团队"
```

### 命名实体约定

确保团队成员使用一致的实体名称：

```bash
# 好的例子
mnemon remember "使用 PostgreSQL 作为主数据库" --cat decision --imp 4

# 避免
mnemon remember "用 pg 做主库"  # 实体提取可能不一致
```

## 🛠️ 不同平台配置

### Windows 配置

```bash
# 1. 安装 Go（使用 scoop）
scoop install go

# 2. 克隆并安装 mnemon
git clone https://github.com/jinyubaba/mnemon.git
cd mnemon
git checkout remote-db
make install

# 3. 配置环境变量（Git Bash）
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PORT=22
export PATH=$PATH:/c/Users/$USER/go/bin
```

详细说明：参考 `WINDOWS_NATIVE.md`

### macOS 配置

```bash
# 1. 安装 Go（使用 Homebrew）
brew install go

# 2. 克隆并安装 mnemon
git clone https://github.com/jinyubaba/mnemon.git
cd mnemon
git checkout remote-db
make install

# 3. 配置环境变量（添加到 ~/.zshrc）
echo 'export MNEMON_REMOTE_HOST=192.168.180.127' >> ~/.zshrc
echo 'export MNEMON_REMOTE_USER=agentdoc' >> ~/.zshrc
echo 'export MNEMON_REMOTE_PORT=22' >> ~/.zshrc
echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.zshrc
source ~/.zshrc
```

### Linux 配置

```bash
# 1. 安装 Go
wget https://go.dev/dl/go1.24.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.1.linux-amd64.tar.gz

# 2. 克隆并安装 mnemon
git clone https://github.com/jinyubaba/mnemon.git
cd mnemon
git checkout remote-db
make install

# 3. 配置环境变量（添加到 ~/.bashrc）
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
echo 'export MNEMON_REMOTE_HOST=192.168.180.127' >> ~/.bashrc
echo 'export MNEMON_REMOTE_USER=agentdoc' >> ~/.bashrc
echo 'export MNEMON_REMOTE_PORT=22' >> ~/.bashrc
source ~/.bashrc
```

## 🔧 Claude Code 集成

### 团队统一配置

在项目的 `.claude/settings.local.json` 中：

```json
{
  "env": {
    "MNEMON_REMOTE_HOST": "192.168.180.127",
    "MNEMON_REMOTE_USER": "agentdoc",
    "MNEMON_REMOTE_PORT": "22"
  }
}
```

**注意**：每个成员需要根据自己的系统调整 PATH 配置。

详细说明：参考 `CLAUDE_CODE_REMOTE_SETUP.md`

## 📊 监控和维护

### 数据库状态监控

```bash
# 查看数据库状态
mnemon status

# 输出示例：
# {
#   "total_insights": 150,
#   "edge_count": 450,
#   "db_size_bytes": 2048000,
#   "by_category": {
#     "decision": 25,
#     "fact": 80,
#     "preference": 45
#   }
# }
```

### 定期维护任务

**每周：**
- 检查数据库大小
- 运行垃圾回收：`mnemon gc --threshold 0.3`

**每月：**
- 备份数据库
- 审查访问日志
- 更新 mnemon 到最新版本

**每季度：**
- 审查和清理过期记忆
- 更新 SSH 密钥（如需要）
- 团队培训和最佳实践分享

## 🚨 故障排除

### 问题 1：无法连接到远程服务器

**症状**：`ssh execution failed`

**解决方案**：

```bash
# 1. 测试 SSH 连接
ssh -v agentdoc@192.168.180.127

# 2. 检查密钥权限
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# 3. 检查服务器是否可达
ping 192.168.180.127
```

### 问题 2：环境变量未生效

**症状**：mnemon 在本地而非远程执行

**解决方案**：

```bash
# 检查环境变量
echo $MNEMON_REMOTE_HOST

# 如果为空，重新加载配置
source ~/.bashrc  # 或 ~/.zshrc

# 或使用脚本
source scripts/setup_remote_env.sh
```

### 问题 3：权限冲突

**症状**：多个成员同时写入导致冲突

**解决方案**：

mnemon 使用 SQLite WAL 模式，支持并发读写。如果遇到锁定问题：

```bash
# 检查是否有长时间运行的进程
ssh agentdoc@192.168.180.127 "ps aux | grep mnemon"

# 如果需要，清理 WAL 文件
ssh agentdoc@192.168.180.127 "cd ~/.mnemon/data/default && sqlite3 mnemon.db 'PRAGMA wal_checkpoint(FULL);'"
```

## 📚 相关文档

- `REMOTE_SETUP_COMPLETE.md` - 远程数据库配置完成说明
- `WINDOWS_NATIVE.md` - Windows 原生环境配置
- `CLAUDE_CODE_REMOTE_SETUP.md` - Claude Code 配置指南
- `WINDOWS_SSH_KEY_SETUP.md` - SSH 密钥配置详细步骤

## 💡 团队使用技巧

### 1. 使用命名存储（Stores）

为不同项目创建独立的存储：

```bash
# 项目 A
export MNEMON_STORE=project-a
mnemon remember "项目 A 的配置信息" --cat fact --imp 4

# 项目 B
export MNEMON_STORE=project-b
mnemon remember "项目 B 的配置信息" --cat fact --imp 4
```

### 2. 定期同步和回顾

建议团队定期（如每周）：

```bash
# 查看最近添加的记忆
mnemon recall "最近一周" --limit 20

# 回顾重要决策
mnemon recall "decision" --limit 10
```

### 3. 知识传承

新成员加入时：

```bash
# 查看项目关键决策
mnemon recall "架构 OR 技术选型" --limit 20

# 查看团队偏好
mnemon recall "preference" --limit 10
```

## 🎯 下一步

1. **管理员**：完成服务器配置和备份策略
2. **团队成员**：按照本指南完成个人配置
3. **团队**：建立记忆分类和标签约定
4. **定期**：审查和优化团队知识库

## ✅ 检查清单

**管理员：**
- [ ] 远程服务器已配置
- [ ] 备份策略已建立
- [ ] 访问控制已设置
- [ ] 监控机制已部署

**团队成员：**
- [ ] mnemon 已安装
- [ ] SSH 密钥已配置
- [ ] 环境变量已设置
- [ ] 连接测试通过
- [ ] 已了解团队约定

**团队：**
- [ ] 分类和标签约定已确立
- [ ] 最佳实践已分享
- [ ] 定期维护计划已制定
- [ ] 故障处理流程已明确
