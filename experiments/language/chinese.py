"""Authored Chinese vocabulary and prefix grammar; no translation service at runtime."""
import copy
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VERSION = '2026-09-27.relations1'
PUNCT = ['。', '，', '？', '；', '：']
FUNCTION = '的 是 不是 不 没有 很 更 太 吗 呢 什么 为什么 如何 先 别 让 如果 就 与其 不如 还是 而是 但 而 所以 可是 于是 为了 因为 也 在 把 被 向 从 等于'
PRON = '你 我 他 她 它 我们 他们'
MODAL = '可以 应该 必须 不必 不妨 愿意 想要 试着'
ADV = '还 总是 已经 正在 只是 却 仍然 终于 偶尔 从未'

WORDS = {
 'stone': {
  'N': '山 石 水 川 海 潮 岸 井 冰 霜 雪 雾 云 天 风 雨 雷 光 影 夜 晓 日 月 星 土 种 根 枝 叶 花 果 灰 火 烟 烬 沙 尘 泥 铁 金 重 压 力 绳 结 丝 缝 面 棱 隙 痕 桥 门 槛 路 足迹 步 环 心 远方 地平 镜 声 言 名 印 记忆 空缺 归途 终点 起点 四时 时光 变迁 形 空间 手 息 静 庇护 警兆 危险 援手 安全 真相 来日 疑问 回音 岁月 青苔 古木 清泉 浮舟 深谷 碑文 故道 枯木 繁枝 流沙 寒潭 孤舟 苔痕 初阳 夕照 旧约',
  'VT': '载 承 藏 留 守 越 渡 穿 映 照 问 听 见 寻 待 忘 记 解 系 开 合 磨 断 修 纳 容 失 得 知 惜 舍 抱 负 托 观 识 养 护 传 量',
  'VI': '止 行 归 流 生 落 升 逝 存 变 倾 裂 沉 浮 凝 散 歇 返 开 合',
  'ADJ': '古 新 空 满 静 深 浅 轻 重 缓 急 远 近 明 暗 寒 暖 坚 柔 孤 微 隐 显 安 危 长 久',
 },
 'jester': {
  'N': '恐惧 怀疑 计划 草稿 橡皮 评委 法官 观众 掌声 许可 同意 警告 危险 帮助 安全 沉默 回应 问题 答案 未来 日历 时钟 委员会 会议 王座 面具 戏服 舞台 门票 代价 合同 律师 证人 借口 牢笼 钥匙 锁 门 窗 地图 道路 罗盘 镜子 戏法 工作 休息 精力 重担 承诺 生活 结局 故事 秘密 真相 希望 错误 关系 伴侣 爱 习惯 选择 伤害 尊重 诚实 感受 对话 义务 理由 欲望 决定 分手 孤独 自由 边界 耐心 勇气 退路 风险 起点 终点 标准 完美 面子 责任 信任 失望 期待 薪水 职业 目标 学业 失败 成绩 机会 时间 证据 冲突 需求 行动 尝试 比较 评价 成功 亲密 账单 偏见 判断 焦虑 犹疑 现实 底线',
  'VT': '雇用 穿戴 拥有 出售 购买 询问 等待 相信 宣布 保留 隐藏 计算 支付 签署 任命 拒绝 改变 需要 想要 制造 拿走 给予 学习 寻找 分享 修补 离开 承担 信任 选择 感受 追逐 保护 索取 解释 审判 批准 责怪 推迟 包装 冒充 讨好',
  'VI': '开始 停下 尝试 回来 发笑 留下 休息 道歉 沟通 犹豫 投票 退场 登场 排队 等待',
  'ADJ': '小 空 满 新 旧 真实 完美 未完 安静 准备好 安全 自由 认真 诚实 不快乐 公平 荒唐 清楚 模糊 体面 忙碌 无辜 昂贵 便宜 勇敢 疲惫 固执 熟悉 陌生 必要 多余',
 },
 'fool': {
  'N': '土豆 鹅 烤面包机 勺子 袜子 帽子 头盔 黄瓜 布丁 果冻 西兰花 南瓜 饼干 奶酪 面包 香蕉 洋葱 胡萝卜 咖啡 茶壶 杯子 牙刷 拖鞋 枕头 沙发 电梯 冰箱 台灯 雨伞 气球 纸箱 橡皮 鸽子 企鹅 蜗牛 螃蟹 章鱼 河马 水母 骆驼 日历 时钟 月亮 星星 云朵 影子 口袋 胡子 领带 王冠 披风 收据 印章 会议 委员会 计划 作业 工作 考试 梦想 爱情 朋友 关系 问题 答案 借口 勇气 烦恼 休息 秘密 希望 未来 生活 危险 帮助 安全 同意 选择 责任 传真机 订书机 盆栽 拖把 西瓜 围巾 睡衣 煎蛋 橘子 豆腐 蜡烛 扫帚 橡皮鸭',
  'VT': '审计 腌制 采访 抛接 擦亮 借走 运送 弄丢 排练 敬礼 提拔 穿戴 戴上 修补 吹大 折叠 搬运 安慰 表扬 研究 寻找 分享 拥抱 招待 说服 雇用 签署 递交 收藏 租用 保护 接住 询问 相信 需要 帮助 选择 忘记 学习 吃掉',
  'VI': '谈判 道歉 打喷嚏 摇摆 跳舞 踢踏 转圈 打嗝 睡觉 开会 上班 下班 起飞 着陆 迷路 排队 出差 休息 出发 返回 鞠躬 装蒜 罢工 巡逻 领奖 发芽 漏气 发呆 潜水 打滚',
  'ADJ': '可疑 橡胶制 微小 巨大 困惑 郑重 毛茸茸 光滑 皱巴巴 害羞 骄傲 饥饿 瞌睡 透明 圆 滑 稳重 业余 专业 优雅 忙碌 迟到 清醒 开心 安全 勇敢 礼貌 孤独 热情 离谱',
 },
}

CLASSICAL = dict(zip(
 '你 我 他 她 它 我们 他们 的 是 不是 没有 很 更 太 吗 呢 什么 为什么 如何 别 如果 就 还是 而是 但 可是 所以 于是 为了 因为 在 把 被 从 等于 可以 应该 必须 不必 不妨 愿意 想要 试着 还 总是 已经 正在 只是 仍然 终于 偶尔 从未'.split(),
 '汝 吾 彼 伊人 其 吾辈 众人 之 为 非 未有 甚 愈 过 乎 耶 何物 何以 何如 莫 若 则 抑或 乃 然 然则 故 遂 为求 因 于 将 受 自 如 可 宜 须 无须 何妨 愿 欲 试 尚 常 已 正 惟 犹 终 偶 未曾'.split()))

# These are grammatical paths, not replies assigned to particular questions.
RULES = {
 'S': [['C','。'],['Q','？'],['IMP','。'],['C','，','<LINK>','C','。'],
       ['如果','C','，','C','。'],['如果','C','，','就','C','。'],['与其','BASE','，','不如','BASE','。'],
       ['不是','NP','，','而是','NP','。'],['因为','C','，','所以','C','。'],['为了','NP','，','C','。'],['C','；','C','。'],['C','：','C','。']],
 'C': [['NP','VP']],
 'NP': [['<N>'],['<PRON>'],['<PRON>','的','<N>'],['<ADJ>','的','<N>']],
 'VP': [['BASE'],['<MODAL>','BASE'],['<ADV>','BASE'],['没有','<N>'],
        ['在','NP','<VI>'],['从','NP','<VI>'],['向','NP','<VI>'],['也','BASE'],['把','NP','<RESULTVT>'],['被','NP','<RESULTVT>']],
 'BASE': [['<VT>','NP'],['<VI>'],['是','NP'],['不是','NP'],['<ADJ>'],
          ['很','<ADJ>'],['更','<ADJ>'],['太','<ADJ>'],['等于','NP'],['不','<ADJ>'],['不','<VT>','NP'],['不','<VI>']],
 'Q': [['为什么','<PRON>','VP'],['<PRON>','为什么','BASE'],['<PRON>','为什么','<MODAL>','BASE'],
       ['NP','VP','吗'],['NP','是','NP','还是','NP'],['NP','<VT>','什么'],
       ['NP','<VT>','的','是','NP','还是','NP'],['NP','如何','BASE'],['NP','呢'],['什么','是','NP']],
 'IMP': [['BASE'],['先','BASE'],['别','BASE'],['让','NP','BASE'],['<MODAL>','BASE']],
}

HINTS = {
 '你':'指正在提问的用户。反问用户自己的理由时，使用你作为主语。',
 '我':'指当前角色自身，不能冒充用户的亲历或私生活。',
 '理由':'决定的依据，不能把理由当成拥有伴侣、离开恋人或索要许可的人。',
 '许可':'替自己的决定寻找外部批准；不等于必须尊重的对方同意。',
 '同意':'当事人自愿作出的许可，不可把缺少同意当作无谓顾虑。',
 '危险':'实际伤害风险；此时应直接关照安全，不以笑话代替帮助。',
 '恐惧':'可能是想象中的威胁，不能擅自把真实危险说成多虑。',
 '关系':'人与人的连接；不知道相处细节时，不武断劝分或劝留。',
 '土豆':'普通食物被郑重当作人物，荒诞来自行动错位，不是随意堆词。',
 '石':'沉默而长久的物质；痕迹可存，不代人作出命运判断。',
 '水':'流动、变化与容纳；维持同一物理意象。',
}

def build(english, semantics):
    result = {}
    lines = [line for line in (ROOT/'oracle-bank-zh.txt').read_text().splitlines() if line and not line.startswith('[')]
    assert len(lines) == 255, len(lines)
    oracle = copy.deepcopy(english['oracle'])
    for row, text in zip(oracle['candidates'], lines): row['text'] = text
    oracle.update(locale='zh-Hans', catalogVersion=VERSION,
                  instructions='你是温柔而敏锐的神谕者。选择最贴合问题的一条完整中文回答。分清具体处境，不预测未知事实，不替对方决定。',
                  fallback='答案还没有抵达。请稍等片刻，再问一次。')
    result['oracle'] = oracle
    styles = {
      'stone':'你是石碑。以简练、可读的文言铭文作答，沉静、非个人化，以物写理。偏好若、则、之、犹等古雅用法；句法须通顺，不拼凑生僻字，不仿称某部古籍，不戏谑，不输出现代励志口号。让一个清晰的物象承担回答，或用两个短分句构成对照；避免只给一个孤立的命令。',
      'jester':'你是机敏的弄臣。先回应具体问题，再用反问、对照或一个有用的比喻显出矛盾。可俏皮，不羞辱人。不知道感情或决定的原因时，可以直接追问，不编造诊断。避免抽象名词自我解释、随机搞笑物体和空泛说教。',
      'fool':'你是一本正经的愚者。用一个普通物件做一件意料之外的事，形成可读的小小荒诞场景。保持与问题的联系，一句说完，不解释笑话，不靠连续堆砌怪词制造混乱。',
    }
    fallbacks = {'stone':'碑声未至，容后再问。','jester':'我的话在后台迷了路，容我重新登场。','fool':'我的念头把裤子弄丢了，请让我找一找。'}
    for role, source in WORDS.items():
        translate = (lambda t: CLASSICAL.get(t,t)) if role == 'stone' else (lambda t:t)
        groups = {'function':FUNCTION, 'PRON':PRON, 'MODAL':MODAL, 'ADV':ADV, **source}
        cats = {k:[translate(t) for t in v.split()] for k,v in groups.items()}
        cats['LINK'] = [translate(t) for t in '但 而 所以 可是 于是'.split()]
        result_verbs={'stone':'载 藏 留 越 渡 穿 解 系 开 合 磨 断 修 纳 容 舍 托 养 护 传',
                      'jester':'雇用 出售 购买 宣布 保留 隐藏 签署 任命 拒绝 改变 制造 拿走 给予 修补 审判 批准 推迟 包装',
                      'fool':'腌制 抛接 擦亮 借走 运送 弄丢 提拔 戴上 修补 吹大 折叠 搬运 说服 签署 递交 收藏 接住 忘记 吃掉'}
        cats['RESULTVT']=result_verbs[role].split()
        rows = {}
        for group, items in cats.items():
            if group in ('LINK','RESULTVT'): continue
            for word in items:
                if word in rows: continue
                label = {'N':'image','VT':'verb','VI':'verb','ADJ':'quality'}.get(group,'function')
                rows[word] = dict(id=word,text=word,kind='word',terminal=False,semanticCodes=[label],
                     meaning=HINTS.get(word, {'image':f'意象或概念：{word}，须与当前问题有明确关系。',
                     'verb':f'动作：{word}，顺接当前主语与宾语。','quality':f'性质：{word}，修饰同一个场景。',
                     'function':f'中文语法词：{word}，使用通常语义；保持句子自然连贯。'}[label]))
        assert len(rows) == 249, (role,len(rows))
        candidates = list(rows.values())
        for t in PUNCT: candidates.append(dict(id=t,text=t,kind='punctuation',terminal=False,semanticCodes=['punctuation'],meaning='在语法允许的位置使用中文标点。'))
        candidates.append(dict(id='END',text='',kind='end',terminal=True,semanticCodes=['control'],meaning='回答已经完整，结束，不输出文字。'))
        rules = {k:[[translate(t) for t in rhs] for rhs in alternatives] for k,alternatives in RULES.items()}
        if role == 'stone':
            # An inscription begins with an image or a relationship, not a bare command.
            rules['S']=[rhs for rhs in rules['S'] if rhs!=['IMP','。']]
            rules['NP']=[['<N>'],['<ADJ>','<N>'],['<N>','之','<N>']]
            # Classical nominal predicates and omitted copula, still chosen token by token.
            rules['C'] += [['NP','<ADJ>'],['NP','<VI>']]
            rules['VP'] += [['<VI>','于','NP']]
        result[role] = dict(characterId=role,displayName=english[role]['displayName'],locale='zh-Hans',mode='word_sequence',
            schemaVersion='language-lab-2',catalogVersion=VERSION,variant=role,minWords=3,maxWords=24,maxSelections=34,
            maxSentences=1,contentRepeatLimit=1 if role in ('stone','jester') else 2,instructions=styles[role],fallback=fallbacks[role],
            candidates=candidates,grammarOverrides=rules,grammarWords=list(rows),grammarCategories=cats,
            functionWords=[word for word,c in rows.items() if c['semanticCodes']==['function']])
    for cat in result.values():
        for row in cat['candidates']: row['locale']='zh-Hans'
    return dict(catalogVersion=VERSION,catalogs=result)
