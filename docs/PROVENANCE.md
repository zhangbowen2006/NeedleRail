# 来源与身份

参赛者为张博文，用户指定新 GitHub ID `zhangbowen200602`，旧账号为 [zhangbowen2006](https://github.com/zhangbowen2006)。更换账号不代表不同参赛者，不能重置报名次数。最终发布身份以实际核验登录为准。

已读取旧项目 [AgentCanary](https://github.com/zhangbowen2006/AgentCanary) README，它是 AI 工具历史策略回放、审批与标签传播工具。NeedleRail 不依赖或复制其核心；没有查证 AgentCanary 被驳回，不作这种表述。用户提供的 WasmSlim、MoonGate、TideWeave 等初审案例仅作为风险输入，不复制代码再申报。

本次先后撤回 ChronoRel 与 LoadLoom 试验：直接注册表发现 [MoonAllen](https://github.com/yujieMamba/moonallen)，GitHub 搜索发现 [fatigue-spectrum](https://github.com/gckbbrant/fatigue-spectrum)，分别高度覆盖其核心。它们保留在本地独立目录，不作为本项目提交，也未向新项目复制核心、测试结果或提交历史。NeedleRail 通过官方 moon new 单独初始化。

几何细分、弧长采样、奇偶扫描线均为已有方法，本项目的工作是实现可组合的针迹编译链与可执行输出，并非新数学算法。开发时阅读了 [pyembroidery DstWriter](https://github.com/EmbroidePy/pyembroidery/blob/main/pyembroidery/DstWriter.py)，参考其 MIT 许可下的 DST 位布局、屏幕 y 翻转和头部约定；编码采用数据表组织。MIT 全文保留在本目录，明确存在参考关系，不将格式编码冒充全新发明。

[Ink/Stitch](https://github.com/inkstitch/inkstitch) 用于功能比较，没有复制其 GPL 源码或作为运行依赖。项目不声称得到这些项目授权背书或被其认证。

运行时仅依赖 MoonBit core（Apache-2.0）及用于 CLI 文件读写的 Node.js；开发复核使用 pyembroidery 1.5.1（MIT），不打包进生产计算。样例是本项目合成几何，不含客户图样或个人资料。

AI 辅助了调研、实现、测试与工程文档。用户须能解释针距、弧长采样、扫描线孔洞、DST 编码、跳针与剪线的差别。未代写正式比赛申报书，空白提纲供本人填写。
