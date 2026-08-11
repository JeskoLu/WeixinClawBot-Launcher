# Security Policy

## Supported version

当前支持最新 Release。

## 报告安全问题

请不要在公开 Issue 中粘贴以下内容：

- `.env`；
- 微信 Token 或账号 ID；
- API Key；
- Hermes 配置、日志、会话原文；
- Windows 用户目录截图。

请通过 GitHub 私密安全报告（Private vulnerability reporting）联系维护者。

## 项目边界

本项目只负责启动和守护本机 Hermes Gateway，不负责：

- 存储微信凭据；
- 代理模型 API；
- 上传 Hermes 会话；
- 绕过 Windows 或微信安全机制。

## 校验发布文件

Release 提供 `SHA256SUMS.txt`。Windows PowerShell 可运行：

```powershell
Get-FileHash .\WeixinClawBot-OneClick.exe -Algorithm SHA256
```

结果应与 Release 中公布的值一致。
