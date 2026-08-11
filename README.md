# WeixinClawBot Launcher

> Windows 上的 Hermes Agent 微信网关一键连接启动器，附带崩溃自愈守护脚本。

[![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-blue)](#系统要求)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Download](https://img.shields.io/badge/download-latest%20release-orange)](https://github.com/JeskoLu/WeixinClawBot-Launcher/releases/latest)

## 项目用途

WeixinClawBot Launcher 面向已经安装并配置好 **Hermes Agent + Weixin** 的 Windows 用户：

- 双击 EXE 检查 Hermes Gateway 是否正在运行；
- 网关未运行时，调用守护脚本自动启动；
- 弹窗显示连接成功或失败；
- 守护脚本每 30 秒检查一次，网关退出后自动重新拉起；
- 可配合 Windows 登录自启，实现长期在线。

> [!IMPORTANT]
> 本项目不是 Hermes Agent 安装器，也不包含模型密钥、微信凭据或用户配置。第一次使用前，请先安装 Hermes Agent，并运行 `hermes gateway setup` 完成 Weixin 扫码绑定。

## 快速使用

### 1. 准备 Hermes Agent

1. 从 [Hermes Agent 官方文档](https://hermes-agent.nousresearch.com/docs/) 安装 Hermes；
2. 在终端运行：

```text
hermes gateway setup
```

3. 选择 **Weixin**，按照提示扫码完成绑定；
4. 可用以下命令检查：

```text
hermes gateway status
```

### 2. 下载启动器

打开 [Releases](https://github.com/JeskoLu/WeixinClawBot-Launcher/releases/latest)，下载：

- `WeixinClawBot-OneClick.exe`：单文件启动器；
- `WeixinClawBot-Launcher-v1.0.0.zip`：包含 EXE、守护脚本和使用说明的完整包；
- `SHA256SUMS.txt`：校验文件。

### 3. 安装守护脚本

将以下两个文件复制到：

```text
%LOCALAPPDATA%\hermes\gateway-service\
```

文件：

```text
Hermes_Gateway_Watchdog.vbs
Hermes_Gateway_Startup.vbs
```

如果你设置了 `HERMES_HOME`，则复制到：

```text
%HERMES_HOME%\gateway-service\
```

### 4. 一键连接

双击 `WeixinClawBot-OneClick.exe`。连接成功后，即可在手机微信中向机器人发送消息。

更详细的初学者说明见：[使用说明.md](使用说明.md)。

## 功能特性

| 功能 | 说明 |
|---|---|
| 一键检查 | 自动识别 Hermes 目录并检查 Gateway 进程 |
| 自动启动 | 网关未运行时调用守护脚本拉起 |
| 崩溃自愈 | Watchdog 每 30 秒检查并自动重启 |
| 隐藏运行 | 启动与守护过程不常驻命令行窗口 |
| 隐私清洗 | 仓库和 EXE 不包含用户名、微信 ID、Token、API Key |
| 开源可审计 | Python 与 VBS 源码均可查看 |

## 系统要求

- Windows 10 或 Windows 11（x64）；
- 已安装 [Hermes Agent](https://github.com/NousResearch/hermes-agent)；
- 已通过 `hermes gateway setup` 配置 Weixin；
- Hermes 默认目录为 `%LOCALAPPDATA%\hermes`，或已正确设置 `HERMES_HOME`。

## 项目结构

```text
WeixinClawBot-Launcher/
├── src/
│   ├── weixin_launcher.py
│   ├── Hermes_Gateway_Watchdog.vbs
│   └── Hermes_Gateway_Startup.vbs
├── assets/
│   └── icon.ico
├── release/                 # 本地 Release 构建产物，不进入 Git 历史
├── README.md
├── 使用说明.md
├── RELEASE_NOTES.md
├── SECURITY.md
├── requirements.txt
└── LICENSE
```

## 从源码运行

```text
python src\weixin_launcher.py
```

运行源码只使用 Python 标准库。

## 自行打包 EXE

```text
python -m pip install -r requirements.txt
python -m PyInstaller --onefile --noconsole --clean ^
  --icon assets\icon.ico ^
  --name "WeixinClawBot-OneClick" src\weixin_launcher.py
```

生成文件位于：

```text
dist\WeixinClawBot-OneClick.exe
```

## 工作原理

```text
手机微信
   │
   ▼
Hermes Weixin Adapter
   │
   ▼
Hermes Gateway  ◄──── Watchdog 每 30 秒探活
   │                       │
   └────────退出时─────────┘ 自动重启
```

## 常见问题

### 弹窗提示连接失败

依次检查：

```text
hermes doctor
hermes gateway status
hermes gateway run
```

日志通常位于：

```text
%LOCALAPPDATA%\hermes\logs\gateway.log
```

### EXE 被安全软件提示

该文件由 PyInstaller 打包且未购买商业代码签名证书，部分安全软件可能产生误报。你可以：

1. 校验 Release 中公布的 SHA-256；
2. 阅读并自行打包仓库源码；
3. 将文件提交到 VirusTotal 进行多引擎检测。

### 能否把 `.env` 上传到仓库？

不能。`.env` 可能包含模型密钥、微信账号信息和令牌，绝对不要提交或公开。

## 安全与隐私

- 本仓库不包含任何真实微信账号 ID、Token 或 API Key；
- 路径通过 `HERMES_HOME`、`LOCALAPPDATA` 或当前用户目录解析；
- `.gitignore` 已排除 Hermes 运行数据、日志、会话和环境变量文件；
- 安全问题请参阅 [SECURITY.md](SECURITY.md)。

## 相关链接

- [Hermes Agent 官方文档](https://hermes-agent.nousresearch.com/docs/)
- [Hermes Agent GitHub](https://github.com/NousResearch/hermes-agent)
- [本项目 Releases](https://github.com/JeskoLu/WeixinClawBot-Launcher/releases)

## 免责声明

本项目为社区工具，与 Nous Research 或腾讯无官方隶属关系。用户应遵守 Hermes Agent、微信及相关服务条款，并自行保管账号凭据。

## License

[MIT License](LICENSE)
