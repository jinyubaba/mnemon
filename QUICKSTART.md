# 快速参考：Mnemon 远程数据库

## 🚀 快速开始（5 分钟）

### 远程服务器 (192.168.180.127)

```bash
# 1. 登录
ssh agentdoc@192.168.180.127

# 2. 安装 mnemon
cd ~
git clone https://github.com/mnemon-dev/mnemon.git
cd mnemon
git checkout remote-db
make install

# 3. 验证
mnemon --version
mnemon status

# 4. 退出
exit
```

### 本地机器

```bash
# 1. 安装 sshpass
sudo apt-get install sshpass  # Ubuntu/Debian
brew install sshpass           # macOS

# 2. 配置远程连接
bash scripts/setup_remote.sh
# 输入：
#   Host: 192.168.180.127
#   User: agentdoc
#   Password: js20220113
#   Port: 22

# 3. 加载配置
source ~/.mnemon/remote.conf

# 4. 测试
mnemon status
```

## ✅ 验证步骤

```bash
# 1. 查看状态
mnemon status

# 2. 创建记忆
mnemon remember "测试记忆" --cat general --imp 3

# 3. 查询记忆
mnemon recall "测试"

# 4. 在远程服务器验证
ssh agentdoc@192.168.180.127
mnemon recall "测试"
exit
```

## 🔧 常用命令

```bash
# 环境变量
export MNEMON_REMOTE_HOST=192.168.180.127
export MNEMON_REMOTE_USER=agentdoc
export MNEMON_REMOTE_PASSWORD=js20220113

# 加载配置
source ~/.mnemon/remote.conf

# 切换到本地模式
unset MNEMON_REMOTE_HOST

# 切换回远程模式
source ~/.mnemon/remote.conf
```

## 📁 重要文件

- `~/.mnemon/remote.conf` - 远程配置文件
- `scripts/setup_remote.sh` - 配置脚本
- `SETUP_GUIDE.md` - 完整配置指南
- `docs/zh/REMOTE.md` - 中文文档

## 🐛 故障排除

| 问题 | 解决方案 |
|------|---------|
| sshpass 未找到 | `sudo apt-get install sshpass` |
| SSH 连接失败 | 检查 IP、用户名、密码 |
| mnemon 未找到 | 在远程服务器上重新安装 |
| 权限被拒绝 | 检查密码和 SSH 配置 |

## 📞 获取帮助

详细文档：`SETUP_GUIDE.md`
