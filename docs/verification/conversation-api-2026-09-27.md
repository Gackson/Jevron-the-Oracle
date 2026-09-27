# 对话模块接入验证 · 2026-09-27

接入范围：独立 Python API、现有词库引擎的历史上下文、iOS Domain/HTTPReadingClient/ConversationStore。界面和工程文件由「梳理 iOS 视觉风格与交互」任务负责；该任务注册新测试并补上故障回复来源标签。未覆盖其样式改动。

## 自动验证

- 24 项语言规则测试通过。
- 7 项后端测试通过：三角色完整输出与上下文/标点、供应商异常/截止时间、繁忙回复、并发重复请求只生成一次、输入与配置隔离、缓存上限、HTTP 路由/认证/JSON。
- iOS ConversationTests 7 项通过；ReadingAPITests 5 项常规测试通过。第 6 项联网测试先明确跳过，配置真实测试 URL 后单独执行通过，`origin=jev`、`generationStatus=complete`，3.975 秒。
- 构建与常规测试日志：`/private/tmp/jev-conversation-tests.log`；真实联网日志：`/private/tmp/jev-conversation-live-tests.log`。

测试中的受控模型回包用于接口与边界验证，不能作为模型语言质量证据。

## 真实调用

[结构化实测结果](conversation-api-live-2026-09-27.json)

| 角色 | 结果 | 调用数 | 延迟 | 可见回复 |
|---|---|---:|---:|---|
| Oracle | JEV 完整生成 | 1 | 2.121 秒 | A beginning is not a promise to finish everything. |
| Stone | composition_error，角色保底 | 4 | 9.029 秒 | The echo has not crossed the stone. Ask again. |
| Jester | invalid_model_output，角色保底 | 10 | 29.159 秒 | My words have missed their cue. Give them another entrance. |

结论：APP → HTTPS → JEV 的链路已验证；三角色都能获得可展示的完整回复。Stone/Jester 的真实生成质量仍未通过验收，不能把故障保底计入模型成功率。

## 可体验环境

专属模拟器 `JEV Conversation API`，ID `79103142-A478-4E88-861E-CA9E558B954B`。APP 已关闭样例模式，服务地址 `https://localhost:8443`，仅此模拟器信任本地开发 CA。构建目录 `/private/tmp/jev-conversation-build`，与另一任务隔离。服务需在 Mac 上运行，证书有效期 7 天；重启方法见 [server/README.md](../../server/README.md)。没有部署公网服务或配置真机地址。
