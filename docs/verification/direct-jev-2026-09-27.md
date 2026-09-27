# APP 直连与用户密钥设置验证 · 2026-09-27

用户改为在设置中提供自己的密钥。APP 默认真实模式直接使用 DirectJEVClient 调用 TypeSafe 官方 API，不再要求运行本地服务或填写服务 URL。密钥只存设备 Keychain，可保存、替换、删除；不会进入应用资源。此次集成的设置页由负责样式的任务协同修改，保留其场景和动画改动。

## 通过的验证

- 24 项原语言规则测试。
- 8 项 Python 集成测试，包含手机 JavaScript 引擎与 Python 参考实现的随机前缀候选集合对照；三角色各 255 项词库及提示内容一致。
- 7 项 ConversationTests。
- 6 项离线 DirectJEVTests：三角色完整流程/上下文/标点、截止时间与无密钥、取消、非法输出、Keychain 保存替换删除、固定供应商地址/Bearer 认证/401 故障回复。
- 1 项 KeySettingsTests：真实操作 SecureField，保存、替换、删除并重新进入设置确认状态。保存后编辑框清空，已有用户密钥时测试跳过，避免覆盖。
- 1 项显式启用的真实直连 Oracle 测试，2.152 秒，断言 origin=jev 和 generationStatus=complete；不经过本项目服务器。
- 检查实际构建出的 JEV.app 不包含环境中真实 key 的字节内容；临时真实测试配置已删除。真实测试未向设备 Keychain 写入现有环境 key。

常规测试日志 `/private/tmp/jev-direct-tests.log`，真实调用日志 `/private/tmp/jev-direct-live-tests.log`，结果包 `/private/tmp/jev-direct-live.xcresult`。

## 发现并解决的测试环境问题

早期命令使用 CODE_SIGNING_ALLOWED=NO，导致 Keychain 保存失败。恢复正常模拟器签名后，Keychain 单元测试与设置页 UI 测试均通过。验证密钥功能应使用 Xcode 默认签名配置。

## 范围

当前在专属模拟器 JEV Conversation API（79103142-A478-4E88-861E-CA9E558B954B）验证，未验证实体 iPhone 签名安装。直连 Oracle 的一次成功不代表三角色质量评测完成；Stone/Jester 仍需依据真实样本继续调优。

使用与词库同步方式见 [APP 直连说明](../../ios/DIRECT-JEV.md)。
