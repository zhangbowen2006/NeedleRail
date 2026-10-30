# 来源与身份

参赛者为张博文。最初提出的新 GitHub ID `zhangbowen200602` 经公共查询未能核验；2026-10-30 终端实际授权账号为 [zhangbowen2006](https://github.com/zhangbowen2006)，本人随后明确同意使用该旧账号发布并如实披露，因此本次实际发布身份是 zhangbowen2006，未换号规避报名次数。

公开仓库为 [zhangbowen2006/NeedleRail](https://github.com/zhangbowen2006/NeedleRail)。首次推送前，将 14 个尚未公开的本地提交中预填的新账号作者标签纠正为实际账号，保持提交树、消息、时间与顺序；随后以正常新增提交记录命名空间和发布配置的变化，没有制造开发时长或合并旧项目历史。

已读取旧项目 [AgentCanary](https://github.com/zhangbowen2006/AgentCanary) README，它是 AI 工具历史策略回放、审批与标签传播工具。NeedleRail 不依赖或复制其核心；没有查证 AgentCanary 被驳回，不作这种表述。用户提供的 WasmSlim、MoonGate、TideWeave 等初审案例仅作为风险输入，不复制代码再申报。

本次先后撤回 ChronoRel 与 LoadLoom 试验：直接注册表发现 [MoonAllen](https://github.com/yujieMamba/moonallen)，GitHub 搜索发现 [fatigue-spectrum](https://github.com/gckbbrant/fatigue-spectrum)，分别高度覆盖其核心。它们保留在本地独立目录，不作为本项目提交，也未向新项目复制核心、测试结果或提交历史。NeedleRail 通过官方 moon new 单独初始化。

几何细分、弧长采样、奇偶扫描线均为已有方法，本项目的工作是实现可组合的针迹编译链与可执行输出，并非新数学算法。开发时阅读了 [pyembroidery DstWriter](https://github.com/EmbroidePy/pyembroidery/blob/815d5febaa005c6afb3ec52235caee51a0111082/pyembroidery/DstWriter.py)，参考并改写其 MIT 许可下的 DST 位布局、屏幕 y 翻转和头部约定；编码采用数据表组织。这属于格式编码部分的参考重实现，不是把整个 pyembroidery 或 Ink/Stitch 项目移植到 MoonBit。MIT 全文及原有版权声明保留在本目录，根目录 NOTICE 也列出来源，不将格式编码冒充全新发明。

2026-10-31 核对时，上述固定修订的 DstWriter.py 与开发时保存的参考文件字节一致，SHA256 为 f4653bffd9843ed3dcfebb3f936dbd100ea6eb20087c80813e522793e83517f9。参考源与开发验证库的身份不同：编码参考文件固定到该修订，独立 reader 使用 PyPI pyembroidery 1.5.1，不混称为同一个版本。

[Ink/Stitch](https://github.com/inkstitch/inkstitch) 用于功能比较，没有复制其 GPL 源码或作为运行依赖。项目不声称得到这些项目授权背书或被其认证。

运行时仅依赖 MoonBit core（Apache-2.0）及用于 CLI 文件读写的 Node.js；开发复核使用 pyembroidery 1.5.1（MIT），不打包进生产计算。样例是本项目合成几何，不含客户图样或个人资料。

AI 辅助了调研、实现、测试与工程文档。2026-10-31，参赛者明确确认组委会允许AI辅助撰写申报，并授权制作正式申报书，现已生成 SUBMISSION.md 和同文排版预览。用户须核对正文，并能解释针距、弧长采样、扫描线孔洞、DST 编码、跳针与剪线的差别；不将AI辅助成果声称为纯手工完成。

| 对象 | 实际关系 | 许可证与保留位置 |
|---|---|---|
| NeedleRail 的几何、针迹编译、报告、CLI 与测试 | 本仓库新建实现；AI 辅助，不宣称新算法 | Apache-2.0，根目录 LICENSE |
| pyembroidery DstWriter.py | DST 位布局、坐标方向和头部编码的参考/改写 | MIT；docs/pyembroidery-MIT.txt 保留全文与原声明，NOTICE 记录固定来源 |
| pyembroidery 1.5.1 | 开发时独立读取 DST 核验，不参与生产编译 | MIT；安装时使用上游包，版本受验证脚本检查 |
| MoonBit core 0.10.18+6c83a7f62 | 标准库依赖，未将其源码当成本项目新增工作 | Apache-2.0；上游 LICENSE 链接见 NOTICE |
| Ink/Stitch | 功能对照，未复制其实现或调用其运行程序 | 上游 GPL-3.0；不声称参考了产品功能就拥有其实现，也不声称其 GPL 代码在本仓库 |
