# Mnemon 远程数据库执行清单

## 📋 执行顺序

按照以下顺序执行，每完成一步打勾 ✓

---

## 第一阶段：远程服务器准备

### □ 1. 连接到远程服务器
```bash
ssh agentdoc@192.168.180.127
# 密码：js20220113
```

### □ 2. 检查 Go 环境
```bash
go version
# 需要 Go 1.24+
```

### □ 3. 克隆并安装 mnemon
```bash
cd ~
git clone https://github.com/mnemon-dev/mnemon.git
cd mnemon
git checkout remote-db
make install
```

### □ 4. 验证安装
```bash
mnemon --version
which mnemon
# 应该显示：/home/agentdoc/go/bin/mnemon
```

### □ 5. 测试基本功能
```bash
mnemon status
# 应该显示 JSON 格式的统计信息
```

### □ 6. 创建测试数据（可选）
```bash
mnemon remember "远程服务器测试数据" --cat general --imp 3
mnemon recall "测试"
```

### □ 7. 退出远程服务器
```bash
exit
```

**✅ 远程服务器配置完成**

---

## 第二阶段：本地机器配置

### □ 8. 安装 sshpass

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install sshpass
```

**Windows WSL:**
```bash
wsl
sudo apt-get update
sudo apt-get install sshpass
```

**macOS:**
```bash
brew install sshpass
```

### □ 9. 验证 sshpass
```bash
sshpass -V
# 应该显示版本号
```

### □ 10. 确认在 remote-db 分支
```bash
cd C:\Users\Administrator\Downloads\mnemon
git branch
# 应该显示 * remote-db
```

### □ 11. 运行配置脚本
```bash
bash scripts/setup_remote.sh
```

输入以下信息：
- Remote host: `192.168.180.127`
- Remote user: `agentdoc`
- Remote password: `js20220113`
- Remote port: `22` (直接回车)

### □ 12. 加载配置
```bash
source ~/.mnemon/remote.conf
```

### □ 13. 验证环境变量
```bash
echo $MNEMON_REMOTE_HOST
# 应该输出：192.168.180.127
```

**✅ 本地机器配置完成**

---

## 第三阶段：功能验证

### □ 14. 测试远程连接
```bash
mnemon status
```
**预期结果：** 显示远程服务器的数据库统计信息

### □ 15. 创建新记忆
```bash
mnemon remember "本地客户端测试" --cat decision --imp 4
```
**预期结果：** 返回 JSON，包含新创建的记忆 ID

### □ 16. 查询记忆
```bash
mnemon recall "本地客户端"
```
**预期结果：** 能找到刚才创建的记忆

### □ 17. 测试 link 命令
```bash
# 先获取两个 ID
mnemon recall "测试" --limit 2
# 复制两个 ID，然后执行：
mnemon link <id1> <id2> --type semantic --weight 0.8
```
**预期结果：** 成功创建链接

### □ 18. 测试 forget 命令
```bash
# 使用一个测试 ID
mnemon forget <test_id>
```
**预期结果：** 成功删除记忆

### □ 19. 再次查看状态
```bash
mnemon status
```
**预期结果：** 统计信息已更新

**✅ 功能验证完成**

---

## 第四阶段：数据一致性验证

### □ 20. 在远程服务器验证本地创建的数据
```bash
ssh agentdoc@192.168.180.127
mnemon recall "本地客户端"
exit
```
**预期结果：** 能找到从本地创建的记忆

### □ 21. 在远程创建数据
```bash
ssh agentdoc@192.168.180.127
mnemon remember "远程创建的数据" --cat fact --imp 5
exit
```

### □ 22. 在本地查询远程创建的数据
```bash
mnemon recall "远程创建"
```
**预期结果：** 能找到从远程创建的记忆

**✅ 数据一致性验证完成**

---

## 第五阶段：性能测试

### □ 23. 测试响应时间
```bash
time mnemon status
time mnemon remember "性能测试" --cat general --imp 3
time mnemon recall "性能"
```
**预期结果：** 命令能在合理时间内完成（通常 < 2 秒）

### □ 24. 批量操作测试
```bash
for i in {1..5}; do
  mnemon remember "批量测试 $i" --cat general --imp 3
done
mnemon status
```
**预期结果：** 所有命令成功执行

**✅ 性能测试完成**

---

## 🎉 最终检查

### 所有功能正常工作：
- [ ] 远程服务器上 mnemon 已安装
- [ ] 本地 sshpass 已安装
- [ ] 环境变量已配置
- [ ] `mnemon status` 显示远程数据
- [ ] `mnemon remember` 能创建记忆
- [ ] `mnemon recall` 能查询记忆
- [ ] `mnemon link` 能创建链接
- [ ] `mnemon forget` 能删除记忆
- [ ] 本地和远程数据一致
- [ ] 性能可接受

---

## 📝 记录信息

完成后记录以下信息：

- 远程服务器 IP: `192.168.180.127`
- 远程 mnemon 版本: `_____________`
- 本地 mnemon 版本: `_____________`
- 配置文件位置: `~/.mnemon/remote.conf`
- 测试完成时间: `_____________`

---

## 🔧 如遇问题

参考故障排除文档：
- 完整指南：`SETUP_GUIDE.md` 第五部分
- 快速参考：`QUICKSTART.md`

---

## 📞 下一步

配置成功后，您可以：

1. **日常使用**
   ```bash
   source ~/.mnemon/remote.conf
   mnemon remember "内容" --cat decision --imp 5
   mnemon recall "关键词"
   ```

2. **添加到启动脚本**
   ```bash
   echo "source ~/.mnemon/remote.conf" >> ~/.bashrc
   ```

3. **配置多个客户端**
   - 在其他机器上重复"本地机器配置"步骤
   - 所有客户端将共享同一个远程数据库

---

**配置完成！享受集中式的 AI 记忆管理！** 🎊
