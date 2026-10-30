# 选题调查记录

调查日期：2026-10-30。检索包括官网、Mooncakes CLI 注册表、GitHub 仓库搜索、MoonBit 社区域名检索与成熟跨语言项目。搜索存在索引、关键词与未发布项目盲区；没有检出不能证明不存在竞争项目。最初网页搜索漏掉了实际同类，后续以直接注册表/API 查询纠正，撤回相应推荐。

## 候选一：纠删码与分片修复（放弃）

目标用户是存储服务或离线备份工具作者。核心问题是部分分片丢失后的数据恢复。预期完整场景：备份人员输入对象并分片保存、删除部分分片后重建并比对原始字节；存储维护者输入损坏清单并生成修复分片、用原始摘要校验；分发服务输入对象范围和可用分片、恢复指定范围并与原文切片比对。

[MoonErasure](https://github.com/oyjh0381/MoonErasure) / [Mooncakes](https://mooncakes.io/docs/oyjh0381/moonerasure) 已覆盖 Reed–Solomon、对象流、范围恢复、校验封装、修复计划和增量校验更新。注册表结果为 0.3.0，比网页索引版本更新。Rust 的 [reed-solomon-erasure](https://github.com/rust-rse/reed-solomon-erasure) 是相邻成熟实现；本次未逐文件确认其许可证，不作为移植源。没有足够核心差异，放弃。社区域名检索未找到能改变该判断的新增材料。

## 候选二：不确定时间区间推理（放弃）

目标用户是工作流、档案标注与媒体流程工具作者。三个场景分别为：流程作者输入阶段先后/相接约束，查询可行序关系并验证端点；档案人员输入不确定事件关系，寻找冲突子集并逐条撤回验证；媒体开发者输入剪辑和授权区间的关系，求取满足包含约束的端点序列并核对原约束。

[MoonAllen](https://github.com/yujieMamba/moonallen) / [Mooncakes](https://mooncakes.io/docs/yujieMamba/moonallen)（README 声明 Apache-2.0）已覆盖 13 关系、传播、见证、可能性/蕴含、冲突核和媒体/流程案例。Python [qualreas](https://github.com/alreich/qualreas)（API 已核实 MIT）同样包含网络传播及一致原子分解；Rust [allen-intervals](https://github.com/regexident/allen-intervals)（MPL-2.0）主要比较区间关系。通用 [Z3](https://github.com/Z3Prover/z3) 也是可编码的替代方案，权重协调并不能消除大部分核心重叠。ChronoRel 本地试验停止作为参赛候选，未推送。

## 候选三：几何到机器刺绣针迹编译（最终实现）

真实用户：程序图案开发者、创客空间、刺绣教学人员。明确的几何路径还不是可执行针迹：需要细分针长、决定往返次序、避开孔洞、处理远距离跳针、绣框边界、换色和机器文件编码。这是一条独立的输入到文件生成流程，不是给其他项目做检查附件。

| 项目 | 核心与适用场景 | 与本项目关系及局限 |
|---|---|---|
| [Ink/Stitch](https://github.com/inkstitch/inkstitch)、[针法文档](https://inkstitch.org/docs/stitch-library/) | 成熟的 Inkscape 刺绣设计平台，含 running/satin/fill、底针、路由、字体与多格式输出 | 功能远多于 NeedleRail；本项目不声称替代其专业编辑能力。面向可嵌入 MoonBit 的无界面确定性编译链。未复制 GPL 实现，未调用其程序 |
| [pyembroidery](https://github.com/EmbroidePy/pyembroidery)（已核实 MIT） | 多格式针迹读写、转换、归一化 | 它已有 DST 编码，本项目参考其格式约定并保留 MIT；运行时不调用 Python。在几何折线、双轨和带孔轮廓到针迹方面提供本项目实现。外部复核使用 1.5.1 |
| [libembroidery](https://github.com/Embroidermodder/libembroidery) | 相邻的 C 刺绣格式/几何生态 | 本次未完成 API 与许可证逐项核查，不作为移植源或宣称胜过它；列为后续需要继续审查的替代方案 |

2026-10-30 注册表 `moon search embroidery`、`Tajima`、`satin stitch` 未返回直接同类，`needlework` 仅检出不相关条目；GitHub repository API 查询 `embroidery language:MoonBit`、`stitch language:MoonBit`、`Tajima language:MoonBit`、`DST embroidery MoonBit` 均返回 0 个仓库。MoonBit 社区域名 `embroidery` 查询无结果。这些是具体关键词的当时结果，不是全量代码审计。项目名 `NeedleRail` 的注册表搜索也未命中。

最终选择原因：有独立可执行文件输出，三种针法、几何边界和文件互操作在截止前可完成并验证，运行核心不依赖已有刺绣项目。风险：通用刺绣平台已很成熟，生态需求尚无真实访谈证据，专业打样未做；评委可能认为功能范围或贡献仍不足。不能保证初审或奖项。

## 其他撤回路线

精确覆盖方向被注册表检出的 [loop_invariants dancing_links_exact_cover](https://github.com/moonbit-community/loop_invariants) 覆盖，未继续开发。拼版、裁切与薄膜光学也通过注册表查到了直接同类，未作为新项目申报。

LoadLoom 雨流/载荷谱试验虽然注册表 `rainflow` 无命中，GitHub API 查出 [gckbbrant/fatigue-spectrum](https://github.com/gckbbrant/fatigue-spectrum)，已覆盖雨流、谱、S-N 与 Miner，README 为 Apache-2.0 并披露 Python rainflow 来源，因此也撤回。没有把“加续算和均值修正”视为足够新项目贡献，未推送。NeedleRail 不复制这些核心。

## 三场景的完整验证链

1. 创客输入 `examples/outline.json`，执行 CLI，得到双色徽标 `.dst/.svg/.json`；Node 比对针距与绣框，pyembroidery 逐条解码，与报告一致。
2. 图案作者输入 `examples/satin.json` 双轨和密度，执行同一 CLI；得到弧长对应的交替针位及文件，检查端点、长度与记录；超宽和交叉输入必须报错。
3. 教学人员输入 `examples/patch.json` 带孔轮廓与边框；生成填充和换色外边框，检查孔内无缝制点、跨孔区间是跳针，外部解码核对位置、命令及头部边界。

未做真实材料、机型、剪线行为或成品质量验证。所有示例均为自建合成几何。
