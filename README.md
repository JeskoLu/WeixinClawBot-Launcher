# WeixinClawBot — Hermes WeChat Gateway Launcher

> 一键连接 Hermes Agent 微信机器人的启动器 + 崩溃自愈守护脚本（Windows）

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📖 项目简介

这是一个面向 **Hermes Agent**（Nous Research 的开源 AI 智能体框架）的 Windows 工具集，包含两部分：

1. **一键连接启动器**（`weixin_launcher.py` / 打包成 exe）— 双击即可检查并启动微信网关，弹窗显示连接结果
2. **守护脚本**（`Hermes_Gateway_Watchdog.vbs`）— 每 30 秒检查网关进程，崩溃后自动重启，实现 7×24 小时在线

配合 Hermes 的 **Weixin 适配器**（基于腾讯 iLink Bot API），让个人微信账号拥有一个 AI 机器人，随时随地用手机微信跟 AI 对话。

## ✨ 功能特性

| 功能 | 说明 |
|------|------|
| 🖱️ 一键连接 | 双击 exe，自动检查网关状态并启动 |
| 🔄 崩溃自愈 | 守护脚本每 30 秒探活，网关挂了自动拉起 |
| 🔒 单实例保护 | 启动前自动清理旧守护进程，不堆积 |
| 🚀 开机自启 | 支持注册表 Run 键 / 计划任务两种方式 |
| 📱 手机遥控 | 微信发消息即可与 Hermes AI 对话 |

## 🛠️ 系统要求

- Windows 10/11
- Python 3.8+（打包 exe 需要 PyInstaller）
- [Hermes Agent](https://hermes-agent.nousresearch.com) 已安装并完成 Weixin 平台配置
  ```bash
  pip install aiohttp cryptography
  hermes gateway setup   # 选择 Weixin，扫码绑定微信
  ```

## 📦 快速开始

### 方式一：直接运行源码

```bash
pip install -r requirements.txt
python src/weixin_launcher.py
```

### 方式二：打包成 exe（免 Python 环境）

```bash
pip install pyinstaller
pyinstaller --onefile --noconsole --icon assets/icon.ico \
  --name "WeixinClawBot一键连接" src/weixin_launcher.py
```

打包后把 `dist/WeixinClawBot一键连接.exe` 放到桌面即可。

### 方式三：安装守护脚本（开机自启 + 崩溃自愈）

1. 将 `src/` 下的两个 `.vbs` 脚本复制到 `<HERMES_HOME>/gateway-service/`
2. 注册开机自启（二选一）：

   **注册表 Run 键（当前用户）：**
   ```cmd
   reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v HermesGatewayWatchdog /t REG_SZ /d "wscript.exe \"%LOCALAPPDATA%\hermes\gateway-service\Hermes_Gateway_Startup.vbs\"" /f
   ```

   **计划任务（需要管理员，支持开机即启）：**
   ```powershell
   schtasks /Create /TN "HermesGatewayWatchdog" /TR "wscript.exe %LOCALAPPDATA%\hermes\gateway-service\Hermes_Gateway_Startup.vbs" /SC ONLOGON /RL HIGHEST /F
   ```

3. 重启电脑验证：登录后约 1 分钟内网关自动上线

## 📂 项目结构

```
WeixinClawBot-Launcher/
├── src/
│   ├── weixin_launcher.py        # 一键连接启动器（主程序）
│   ├── Hermes_Gateway_Watchdog.vbs   # 守护脚本（崩溃自愈）
│   └── Hermes_Gateway_Startup.vbs    # 开机自启引导
├── assets/
│   └── icon.ico                  # 程序图标
├── requirements.txt              # Python 依赖
├── README.md                     # 本文件
└── LICENSE                       # MIT 许可证
```

## 🧠 工作原理

```
┌────────────┐   WebSocket/REST   ┌──────────────────┐
│  手机微信   │ ◄────────────────► │  Hermes Gateway   │
└────────────┘                    │  (iLink Bot API)  │
                                  └────────┬─────────┘
                                           │ 守护脚本每30秒探活
                                           ▼
                                  ┌──────────────────┐
                                  │  Watchdog 守护    │
                                  │  挂了自动重启     │
                                  └──────────────────┘
```

## ⚠️ 注意事项

- **隐私安全**：本项目只包含工具代码，**不含任何微信凭证**。请勿将 `<HERMES_HOME>/.env`（内含 `WEIXIN_ACCOUNT_ID`、`WEIXIN_TOKEN` 等敏感信息）提交到仓库
- 守护脚本通过环境变量 `HERMES_HOME` 定位安装目录，未设置时回退到默认位置
- 微信机器人基于 iLink Bot API，普通微信群消息可能无法送达，私聊正常

## 🔗 相关链接

- [Hermes Agent 官网](https://hermes-agent.nousresearch.com)
- [Hermes Agent GitHub](https://github.com/NousResearch/hermes-agent)
- [Hermes 文档 - Weixin 适配器](https://hermes-agent.nousresearch.com/docs)

## 📄 License

[MIT](LICENSE) © 2026
