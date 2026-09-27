"""Render every recorded run, including failures; never manufacture human scores."""
import argparse
from collections import Counter, defaultdict
import json
from pathlib import Path
import statistics

ROOT=Path(__file__).resolve().parent


def render(paths):
    rows=[]
    for path in paths:
        rows.extend(json.loads(line) for line in path.read_text().splitlines() if line.strip())
    lines=["# JEV 真实语言实验记录", "", "此表保留全部实验。origin=jev 的原文来自真实选择；authored_fallback 为明确标记的预写备用回复，不算模型成功。没有润色、挑选或失败重抽。", "",
           "工程终止与响应合法性可自动核对；语义相关、可读性、角色质感尚需人工评分。以下结果不能代表泛化能力。", "",
           "新版禁止 no-match。表中“完成”仅指模型机械闭合，不能代表语法、语义或惊喜程度通过；预写备用回复不算模型完成。历史 seed1 的无匹配仅作旧行为记录。", ""]
    groups=defaultdict(list)
    for row in rows:groups[(row["catalogVersion"],row["variant"],row["encoding"])].append(row)
    lines += ["## 运行汇总", "", "| 词库版本 | 形式 | 编码 | 模型机械完成 / 总数 | JEV 请求数 | 耗时中位数（秒） |", "| --- | --- | --- | --- | --- | --- |"]
    for (version,variant,encoding),rs in groups.items():
        lines.append(f"| {version} | {variant} | {encoding} | {sum(r['status']=='complete' and r.get('origin','jev')=='jev' for r in rs)} / {len(rs)} | {sum(r['calls'] for r in rs)} | {statistics.median(r['latencyMs'] for r in rs)/1000:.2f} |")
    usage=Counter()
    for r in rows:
        for s in r["steps"]:
            u=s.get("response",{}).get("usage",{})
            for key in ("input_tokens","output_tokens"):
                if type(u.get(key)) is int:usage[key]+=u[key]
    lines += ["",f"供应商返回的已知 token 用量：input={usage['input_tokens']}，output={usage['output_tokens']}。超时或未返回 usage 的调用不包含在这个合计中。", "",
              "## Oracle 重复测试（无缓存）", "", "| 版本 / 编码 | 问题 | 模态 ID / 完成结果数 | 完成 / 总数 | 不同选择 |", "| --- | --- | --- | --- | --- |"]
    og=defaultdict(list)
    for r in rows:
        if r["variant"]=="oracle":og[(r["catalogVersion"],r["encoding"],r["caseId"])].append(r)
    for (version,encoding,case),rs in og.items():
        counts=Counter(tuple(s["candidateId"] for s in r["segments"]) for r in rs if r["status"]=="complete" and r.get("origin","jev")=="jev")
        modal=max(counts.values(),default=0)
        count=sum(counts.values())
        lines.append(f"| {version} / {encoding} | {case} | {modal} / {count} | {count} / {len(rs)} | {', '.join('/'.join(k) for k in counts) or '无'} |")
    lines += ["", "重复次数少于 10 的题仅用于筛查。重复测试失败也保留在分母说明中；模态占比不是答案适当率。", "", "## 全量逐题输出", ""]
    by_case=defaultdict(list)
    for row in rows:by_case[row["caseId"]].append(row)
    for case,rs in by_case.items():
        lines += [f"### {case}", "",rs[0]["question"],"", "| 版本 / 编码 | 形式 | 次数 | 原样输出（/ 表示片段分隔） | 状态 | 秒 |", "| --- | --- | --- | --- | --- | --- |"]
        for r in rs:
            text=(r.get("text") or " / ".join(s["text"] for s in r["segments"])).replace("|","\\|") or "（无内容）"
            lines.append(f"| {r['catalogVersion']} / {r['encoding']} | {r['variant']} | {r['repeat']+1} | {text} | {r.get('origin','legacy')} / {r['status']}:{r['stopReason']} | {r['latencyMs']/1000:.2f} |")
        lines.append("")
    return "\n".join(lines)+"\n"


if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("runs",nargs="+")
    p.add_argument("--out",default="RESULTS.md")
    a=p.parse_args()
    out=ROOT/a.out
    out.write_text(render([ROOT/x for x in a.runs]))
    print(out)
