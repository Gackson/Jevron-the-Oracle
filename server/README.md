# JEV conversation service

> 可选开发工具。APP 已支持在设置输入密钥后直接调用 JEV，不需要运行此服务；见 [直连说明](../ios/DIRECT-JEV.md)。

Python 3.9+，无第三方依赖。从项目根目录运行。复用现有三角色词库、隐性编码和有界生成引擎；TypeSafe 密钥只从服务端环境 `TYPESAFE_API_KEY` 或根目录 `.env` 读取。

```bash
bash server/dev_tls.sh
python3 -m server.app --tls-cert server/.local/localhost.crt --tls-key server/.local/localhost.key
```

开发地址：`https://localhost:8443`。证书和私钥生成在忽略目录 `server/.local/`，有效期 7 天；到期后自行移走旧目录再生成。只在专属模拟器信任 CA，不要把私钥随 APP 打包。

```bash
xcrun simctl keychain YOUR_SIMULATOR_ID add-root-cert server/.local/ca.crt
curl --cacert server/.local/ca.crt https://localhost:8443/health
```

在该模拟器 APP 的 Settings 中关闭 Sample replies，服务地址填写 `https://localhost:8443`。模拟器 localhost 可连接 Mac；真机需要可达的 HTTPS 服务地址，不能使用该 localhost。未配置服务地址时仍保持原设置流程，不自动把用户导向开发机。

`GET /health` 的 providerConfigured 仅说明存在密钥，不代表供应商可达。没有密钥仍可验证角色故障回复；其来源明确为 authored_fallback。默认最多同时执行两轮生成，额外请求立即返回角色回复。请求 ID 缓存为进程内、短期、有上限。开发 HTTP 服务器不应直接用作公网生产部署。

```bash
python3 -m unittest discover -s tests/integration -v
python3 -m unittest discover -s experiments/language -p 'test_*.py' -v
```

iOS 测试文件 `ios/JEVTests/ReadingAPITests.swift` 覆盖真实客户端的请求构造、上下文、标点、失败来源、取消、故障轮次过滤。可选联网测试通过 **测试进程**环境变量 `JEV_LIVE_TEST_URL=https://localhost:8443` 启用，需运行此 HTTPS 服务且模拟器信任开发 CA；未启用时明确跳过。测试要求命中服务端词库版本，不能由客户端本地保底蒙混通过；服务端生成结果另报告 origin。

接口详情见 [v2 协议](../docs/IOS-CONVERSATION-API.md)。
