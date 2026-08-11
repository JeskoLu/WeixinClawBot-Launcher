# v1.0.0 发布说明

## WeixinClawBot Launcher 首个公开版本

这是一个适用于 Windows 的 Hermes Agent 微信网关一键连接工具。

### 主要功能

- 双击 EXE 检查并启动 Hermes Gateway；
- 弹窗显示微信机器人连接结果；
- 守护脚本每 30 秒检查网关状态；
- 网关异常退出时自动重启；
- 支持 `HERMES_HOME` 与 Windows 默认 Hermes 目录；
- 源码、守护脚本和图标全部公开。

### 下载建议

- 初学者：下载 `WeixinClawBot-Launcher-v1.0.0.zip`；
- 已安装守护脚本：可只下载 `一键连接.exe`；
- 下载后使用 `SHA256SUMS.txt` 核对完整性。

### 实测结果

- 平台：Windows 11 x64；
- EXE 类型：PE32+ GUI x86-64；
- EXE 大小：11,562,417 字节；
- EXE 启动并正常创建 GUI 窗口；
- EXE 退出码：0；
- 运行后 `hermes gateway status` 显示 Gateway 正常运行；
- 静态扫描未发现本机用户名、绝对用户路径、微信账号 ID、Token 或 API Key。

### 发布文件 SHA-256

```text
f919cbbe445e48ff40422044954118d44ce4e1955e32190762eefbc4a356019b  一键连接.exe
8e21729598bf1b7b0e11ef1841969328a27080cabd0cb0e2e062f4c72031e1d4  WeixinClawBot-Launcher-v1.0.0.zip
```

### 使用前提

本工具不会安装 Hermes Agent，也不会替你创建微信凭据。请先安装 Hermes，并运行：

```text
hermes gateway setup
```

选择 Weixin 完成扫码配置。

### 已知说明

本版本未使用商业代码签名证书。PyInstaller 单文件 EXE 可能被少数安全软件提示，建议核对 SHA-256 或自行从源码构建。
