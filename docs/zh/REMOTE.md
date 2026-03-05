# 快速开始：远程数据库模式

## 概述

`remote-db` 分支添加了通过 SSH 将数据库托管到远程服务器的功能。所有 mnemon 命令都可以透明地在远程服务器上执行。

## 配置步骤

### 1. 在远程服务器上安装 mnemon

```bash
# SSH 登录到您的服务器
ssh agentdoc@192.168.180.127

# 安装 mnemon
go install github.com/mnemon-dev/mnemon@latest

# 或从源码构建
git clone https://github.com/mnemon-dev/mnemon.git
cd mnemon
git checkout remote-db
make install
```

### 2. 在本地安装 sshpass

**Ubuntu/Debian:**
```bash
sudo apt-get install sshpass
```

**Windows (Git Bash/WSL):**
```bash
# 在 WSL 中:
sudo apt-get install sshpass
```

### 3. 配置远程连接

**方式 A: 使用配置脚本（推荐）**

```bash
bash scripts/setup_remote.sh
```

脚本会交互式地询问：
- 远程主机地址
- SSH 用户名
- SSH 密码
- SSH 端口（默认 22）

配置会保存到 `~/.mnemon/remote.conf`

**方式 B: 手动设置环境变量**

```bash
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PASSWORD=js20220113
export MNEMON_REMOTE_PORT=22  # 可选，默认 22
```

### 4. 启用远程模式

```bash
# 加载配置
source ~/.mnemon/remote.conf

# 或者添加到 shell 配置文件
echo "source ~/.mnemon/remote.conf" >> ~/.bashrc
```

## 使用示例

配置完成后，所有命令都会自动在远程服务器上执行：

```bash
# 记忆 - 存储到远程服务器
mnemon remember "选择了 PostgreSQL 作为主数据库" --cat decision --imp 5

# 回忆 - 从远程数据库查询
mnemon recall "数据库"

# 查看状态
mnemon status

# 创建链接
mnemon link <source_id> <target_id> --type semantic --weight 0.8

# 删除记忆
mnemon forget <id>
```

## 工作原理

```
本地客户端                    远程服务器 (192.168.180.127)
┌─────────────┐              ┌──────────────────────┐
│             │              │                      │
│  mnemon CLI │──SSH/sshpass─▶│  mnemon CLI         │
│             │              │  ~/.mnemon/          │
│             │◀──JSON结果───│  (SQLite 数据库)     │
└─────────────┘              └──────────────────────┘
```

1. 本地客户端检测到 `MNEMON_REMOTE_HOST` 环境变量
2. 自动进入远程模式
3. 通过 SSH 将命令转发到远程服务器
4. 远程服务器执行命令并返回 JSON 结果
5. 本地客户端显示结果

## 验证安装

```bash
# 测试远程连接
mnemon status

# 应该看到远程服务器的数据库统计信息
```

## 切换回本地模式

```bash
# 取消设置环境变量
unset MNEMON_REMOTE_HOST
unset MNEMON_REMOTE_USER
unset MNEMON_REMOTE_PASSWORD
unset MNEMON_REMOTE_PORT

# 或者注释掉 ~/.bashrc 中的 source 行
```

## 安全建议

- 当前使用密码认证，适合快速测试
- 生产环境建议使用 SSH 密钥认证
- 密码通过环境变量传递，不会存储在代码中
- 配置文件 `~/.mnemon/remote.conf` 权限设置为 600（仅所有者可读写）

## 故障排除

### sshpass 未找到
```bash
# 安装 sshpass
sudo apt-get install sshpass  # Ubuntu/Debian
```

### SSH 连接失败
```bash
# 测试 SSH 连接
ssh agentdoc@192.168.180.127

# 检查防火墙设置
# 确保端口 22 开放
```

### 远程服务器上 mnemon 未安装
```bash
# SSH 到远程服务器
ssh agentdoc@192.168.180.127

# 检查 mnemon 是否在 PATH 中
which mnemon

# 如果没有，安装它
go install github.com/mnemon-dev/mnemon@latest
```

## 下一步

查看完整文档：
- `docs/REMOTE.md` - 详细的远程模式文档
- `docs/USAGE.md` - 命令参考
- `docs/DESIGN.md` - 架构设计

## 技术细节

- 使用 `sshpass` 进行密码认证
- 所有命令参数和标志都会转发到远程服务器
- JSON 输出直接从远程服务器返回
- 支持所有 mnemon 命令（remember, recall, link, forget, status, log, gc 等）
