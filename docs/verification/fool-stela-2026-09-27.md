# The Stela / The Fool 接入验证

资源版本：`2026-09-27.roles4b`。The Stone 对外改名 The Stela，内部 `stone` ID 保持兼容；新增独立 `fool` 角色、草稿、上下文、样例与故障回复。

- 27 项语言规则测试通过，包含 Fool 的单词粒度、荒诞句式、求助句式、单句停止与尾部结构限制。
- 8 项 API/跨引擎测试通过，覆盖四角色完整路径、异常角色回复、历史传递、缓存与手机 JavaScript/Python 候选集合一致性。
- 最终 iOS 会话与直连测试：15 项，13 项通过，2 项付费实测默认跳过。随后单独启用 Fool 真实直连测试通过，7.535 秒。
- 四角色循环、Fool 缺图占位和原三角色深度资产检查由视觉任务合并验证；其 7 个 SpatialTests 与入口视频/四角色循环 UI 测试通过，结果 `/private/tmp/jev-v4-final-integration.xcresult`。
- 当前词库审阅快照包含四角色共 1020 个候选位，已核对与 APP 资源中的候选完全一致。

[真实样本与前后修订](fool-live-2026-09-27.json)。当前 Fool 原文：**Homework is a potato with a plan.**

初始版本输出里的 “now to work” 不够自然，已明确保留，不计作理想质量。一次改进后的样本只证明该问题能产生可读的荒诞句子，不证明整体内容质量或稳定性。

测试实际使用现有密钥，但只注入临时测试进程，未写入 APP 资源或设备 Keychain；临时配置已删除。Fool 尚无专属角色图，使用开发占位，未借用其他角色形象冒充。

手机测试日志：`/private/tmp/jev-fool-tests-final.log`、`/private/tmp/jev-fool-live-final.log`。
