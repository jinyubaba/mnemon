# 远程数据库设置完成

## 配置信息

- **远程服务器**: 192.168.180.127
- **用户**: agentdoc
- **端口**: 22
- **认证方式**: SSH 密钥认证（无需密码）

## 环境变量设置

在使用 mnemon 前，需要设置以下环境变量：

```bash
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PORT=22
```

## 使用示例

### 1. 添加记忆
```bash
mnemon remember "这是一条测试记忆" --cat fact --imp 5
```

### 2. 查询记忆
```bash
mnemon recall "测试"
```

### 3. 查看状态
```bash
mnemon status
```

## 工作原理

1. 本地 Windows 机器上的 mnemon 检测到环境变量 `MNEMON_REMOTE_HOST`
2. 自动通过 SSH 连接到远程 Ubuntu 服务器
3. 在远程服务器上执行 mnemon 命令
4. 数据存储在远程服务器的 `~/.mnemon` 目录
5. 结果返回到本地机器

## 注意事项

- SSH 密钥已配置，无需输入密码
- 远程服务器上的 mnemon 版本：dev
- 本地机器上的 mnemon 版本：dev
- 数据库文件位于远程服务器：`/home/agentdoc/.mnemon/`

## 测试结果

✅ SSH 密钥认证成功
✅ 远程 mnemon 命令执行成功
✅ remember 命令测试通过
✅ recall 命令测试通过

## 下一步

你现在可以正常使用 mnemon，所有数据都会自动存储在远程服务器上。
