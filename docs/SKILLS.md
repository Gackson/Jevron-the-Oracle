# 本项目的 Skill 选择

日期：2026-09-27。以直接适配任务、已读内容、来源和可验证性选择，不把安装量当质量保证。当前工作为规划，不为凑技能数量新增产品功能。

## 已使用与下一步用途

| Skill | 来源／当前状态 | 在本项目中的作用 |
| --- | --- | --- |
| `find-skills` | 已安装，本轮已读 | 先查已有能力，核对外部技能的来源与普及度 |
| `dispatching-parallel-agents` | 已安装，本轮已读并用于派发三个规划 Agent | 独立上下文、明确文件所有权、交付后由主 Agent 检查并合并 |
| `typesafe-ai` | 项目已安装，skills-lock.json 来源为 `typesafe-ai/skills`；本轮已读 | Choice 与状态设计、显式语义描述、版本绑定、真实数据验证 |
| `design-foundations` / `animations` | 已安装，设计 Agent 已读 | 固定文字层、单一主操作、可访问性、短且可中断的动作、Reduce Motion |
| `imagegen` | 系统技能已安装，本轮已读；未生成图片 | 下一阶段制作角色母图、背景补全、透明图层；明确输出为二维图片 |
| `swiftui-expert-skill` | 已核对并临时下载读取，未全局安装 | 状态归属、拆分高频更新子视图、原生控件、版本兼容、预览隔离网络 |
| `verification-before-completion` | 已安装，本轮已读并用于文档与交付核对 | 区分计划、样例、编译通过、模拟器通过与真机通过，不凭 Agent 汇报声称完成 |

本轮 design-foundations/animations 只读取使用，未进行全局技能同步或软件安装；Web 写法中的 CSS/DOM 细节不直接套入原生界面。

## 新发现：SwiftUI Expert

来源是 [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill)，作者包括 SwiftLee 的 Antoine van der Lee 与 Omar Elsayed；仓库声明 MIT 许可。[skills.sh 页面](https://skills.sh/avdlee/swiftui-agent-skill/swiftui-expert-skill) 在本轮读取时显示约 **33.0K 安装、3.6K GitHub stars**，仅作为采用度证据。

本轮只读克隆到 `/private/tmp/jev-swiftui-skill-reference`，锁定提交：

`b24e68a965dc4b5bd2cc41dc60c094a26a9379ce`

已读取 `skills/swiftui-expert-skill/SKILL.md` 及状态管理、性能相关参考。技能包含 SDK 27 条目，本机只有已确认的 Xcode/SDK 26；仅采纳与目标 SDK 相符的指导，Apple 官方 API 和实际编译结果优先。不要因技能出现 Liquid Glass、复杂架构或新平台功能就加入此项目。

后续若要持久化供新会话自动发现，可在项目范围安装；下面是供执行阶段使用的命令，本轮没有执行安装：

```bash
npx skills add https://github.com/avdlee/swiftui-agent-skill --skill swiftui-expert-skill
```

安装时选择项目范围，避免顺手更新其他技能。临时目录可能被系统清理，未来 Agent 应根据来源与锁定版本重新读取，不把临时文件当产品依赖。

## 不需要增加的东西

- 无需 Figma 流程才能开始：本轮以能直接被原生 App 消费的图片和参数为主要交付。
- 不采用 React/Next.js 专用技能指导 SwiftUI。
- 不增加 3D 建模、RealityKit、USDZ、AR 或深度估计技能；用户已改用分层图片。
- 不假设 imagegen 能直接输出分层 PSD 或保证像素级抠图。母图与每次编辑都需检查实际尺寸、透明度和叠合结果。
- 不用额外大模型解释神谕、润色 JEV 输出或做 P0 必需的自动评委。

## 权威参考

- [TypeSafe 文档索引](https://docs.typesafe.ai/llms.txt)、[Choice](https://docs.typesafe.ai/primitives/choice)、[HTTP API](https://docs.typesafe.ai/api)
- [Apple Speech](https://developer.apple.com/documentation/speech/)
- [Apple Core Motion](https://developer.apple.com/documentation/coremotion/)
- [Apple SwiftUI](https://developer.apple.com/documentation/swiftui/)

执行过程中只在需要的节点读取对应参考；遇到真实错误再展开相关章节。技能帮助做出工程判断，不代替真机、真实候选和网络环境的验收。
