# iOS 连续对话接口 v2

> 最新 APP 已改为用户在设置中提供密钥、设备直接调用 JEV；见 [直连说明](../ios/DIRECT-JEV.md)。本文保留本地服务开发接口，不是使用 APP 的前置条件。

已接通 `server/app.py` → `experiments/language/lab.py` → TypeSafe JEV。APP 的 `HTTPReadingClient` 调用 `POST /v2/readings`（HTTPS、JSON），整包回复到达后执行逐词显现，不是 token 流。每次提交创建新 UUID，不自动重试。

服务端完整生成预算 120 秒，单次供应商请求最多 25 秒；APP 请求超时 150 秒。词库、隐性编码、语法约束、词数/步数/重复上限均复用语言实验实现，APP 不携带 TypeSafe 密钥。

## 请求

```json
{
  "requestId": "97A88F6C-2846-45BD-A1CD-4A467E9DC925",
  "characterId": "oracle",
  "question": "What if I begin today?",
  "locale": "en",
  "history": [
    {"question": "What am I waiting for?", "answer": "Notice which answer you were hoping for."}
  ]
}
```

- 角色只允许 oracle / stone / jester / fool；当前输出语言 en。
- question 去除首尾空白后 1–500 Unicode scalar；拒绝孤立 surrogate。
- history 最多 6 轮，时间正序；每轮 question ≤500、answer ≤1500，合计 ≤12000 scalar。HTTP 请求 ≤64 KiB。
- APP 只发送同角色、同模式的已完成轮次；样例和故障角色回复不进入真实上下文。
- 上下文送入意图选择及每一步候选选择，作为不可信的对话背景；不允许覆盖模型、词库、规则等服务配置。未知请求字段被拒绝。
- 相同 UUID + 相同规范化内容在本进程缓存内复用回复；UUID 内容冲突返回 409。缓存最多 128 项、完成项从创建起保留最多 10 分钟，重启后不保留，不是持久幂等承诺。

## 完整回复

```json
{
  "requestId": "97A88F6C-2846-45BD-A1CD-4A467E9DC925",
  "characterId": "oracle",
  "catalogVersion": "2026-09-27.words4",
  "status": "complete",
  "segments": [{"candidateId": "oracle.composed", "text": "A beginning is not a promise to finish everything."}],
  "stopReason": "rule_complete",
  "origin": "jev",
  "generationStatus": "complete",
  "generationStopReason": "rule_complete",
  "selectedCandidateIds": ["oracle.begin.01"],
  "metrics": {"calls": 1, "latencyMs": 2121}
}
```

服务端先确定性拼接标点，再将全文放入一个 segment，兼容 APP 用空格连接片段的契约。APP 校验请求 UUID、角色、版本、完整状态、来源/停止原因组合以及文本非空且 ≤2000 scalar。

## 每次都能收到角色回复

合法请求没有 `no_match` 分支。超时、服务繁忙、缺少密钥、供应商失败或未能组合成完整句子时，服务端返回该角色的完整保底回复：`status=complete`、`origin=authored_fallback`、`generationStatus=failed`、`stopReason=fallback_complete`。`generationStopReason` 说明内部失败类别，不泄露供应商原始报错。

即使服务器断线、返回不合法数据，APP 也会给出角色保底回复并标明连接不可用，不把它称为 JEV 生成成功。来源记录在 ReadingTurn；不进入下一轮模型上下文。取消、切角色或进入后台则不产生保底回复，旧请求不会写入新角色会话。

协议错误返回 `{requestId, error: {code, retryable}}` 与适当 HTTP 状态。无效 HTTPS 地址仍由设置页提示修正。样例模式保留独立 PreviewReadingClient。

## 本地运行与边界

见 [服务端说明](../server/README.md)。本地开发服务只绑定回环地址，不是已部署的公网后端。非回环绑定要求 `JEV_SERVICE_TOKEN`，HTTPReadingClient 支持独立服务 accessToken；现有设置页仅配置 URL，正式部署前应接入适当的 APP 服务认证。

问题/历史不写入访问日志或持久化；进程内临时缓存完整回复，过期/重启清除。取消 URLSession 不能保证撤回已到达 JEV 的计算，但服务器总预算有界。词库调用效果与连通性分开验证：接口接通不代表 Stone/Jester 语言质量已达标。
