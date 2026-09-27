# APP 直接连接 JEV

APP 内运行四角色词库和组合规则，直接请求 TypeSafe 官方 HTTPS API。无需运行本项目 Python 服务器，也无需填写服务地址。

在 Settings 的 API key 输入框填写自己的 TypeSafe key，保存后关闭 Sample replies，即可直接提问。密钥存入设备 Keychain（仅本机、解锁后访问、不经 iCloud 同步）；可替换或删除。应用源码、资源和导出脚本均不包含真实密钥。问题与上下文会随请求发送给 TypeSafe。

## 回答语言

Settings → Reply language · 回答语言 可选 English / 简体中文，偏好保存在本机。切换后用于下一条回答，已有记录保留原语言；打开设置会取消尚未完成的请求。

两种语言各有独立的四角色词库，每角色255个候选。中文 Oracle 为完整短答；其他三个角色逐词选择中文词并由中文语法收尾，不在客户端调用额外翻译服务。中文保底回复、逐字显示、标点附着和无空格排版一并支持；语音识别跟随语言使用 en-US / zh-CN（实际可用性仍取决于系统权限与识别服务）。

The Stela 英文采用可读的古雅铭文语气（如 hath、doth、abideth、beareth），不是历史语言学意义上完整的 Old English；中文采用简练文言语气，以物象或对照作答。其余角色保持现代语言风格。

词库审阅页 `docs/vocabulary/current-vocabulary.html` 可切换语言；中文完整表见 `docs/vocabulary/chinese-vocabulary.md`。实测记录见 `docs/verification/chinese-stela-2026-09-27.md`。

## 开发结构

- `JEV/DirectJEVClient.swift`：Keychain、固定供应商地址、禁止重定向、异步请求、取消/截止时间、回复校验。
- `JEV/Resources/Language/runtime.json`：从 Python 实验导出的公开词库、隐性编码、语法分类和提示。
- `JEV/Resources/Language/engine.js`：用 iOS 自带 JavaScriptCore 执行离线候选约束；不会运行模型输出代码。
- `JEVTests/DirectJEVTests.swift`：四角色调用流程、历史/标点、故障、截止时间、取消、Keychain 保存/替换/删除与可选真实联网验证。
- `../tests/integration/test_ios_rule_parity.py`：随机前缀下，对比手机与 Python 的候选集合。

编辑实验词库后，从项目根目录同步：

```bash
python3 experiments/language/build_catalogs.py
python3 ios/Tools/prepare-direct-jev.py
python3 -m unittest discover -s tests/integration -p test_ios_rule_parity.py -v
```

编译只需公开的 Language 资源，不读取 `.env`，不注入构建密钥。原 HTTPReadingClient 和本地服务器保留为开发工具，APP 默认真实模式使用 DirectJEVClient。

每个角色仍有 255 个候选；Stela/Jester/Fool 逐词做选择。120 秒总预算、25 秒单请求上限、角色步数/词数/重复限制不变。故障会给出明确标注来源的角色保底回复，用户取消不产生保底。保底回复不会进入下一轮模型上下文。直连改造不代表 Stela/Jester/Fool 输出质量已经通过验收。

验证密钥功能时请使用 Xcode 默认模拟器签名，不要设置 `CODE_SIGNING_ALLOWED=NO`；未签名测试构建无法正确访问 Keychain。
