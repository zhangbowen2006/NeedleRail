# NeedleRail：MoonBit 刺绣针迹编译库

**申报人：**张博文 / zhangbowen2006　 **参赛方式：**个人参赛，新项目申报，参与季度评选　 **版本：**0.1.0

## 项目简介与应用方向

NeedleRail 面向程序化图案、创客及教学工具开发者，将折线、双轨和带孔多边形编译为针迹计划，输出 **Tajima DST 文件、SVG 预览和 JSON 报告**。几何坐标还需要经过针长细分、双轨对应、孔洞处理、绣框约束和换色编排，才能形成可供兼容软件读取的刺绣文件。本项目提供可独立调用的 MoonBit 类型化 API 与 JSON CLI，适合嵌入几何生成应用和自动化工具，核心计算无需调用 Python 或 Inkscape。

## 已实现的核心功能与技术贡献

- **三种针迹编译：**折线保留拐点并细分针长；缎面按两轨归一化弧长配对；填充采用奇偶扫描线与蛇形行序，孔洞两侧分开缝制并用跳针连接。
- **几何与执行边界：**统一使用 0.1 mm 整数坐标，检查绣框和针长，拒绝填充轮廓、缎面轨道的自交与回退；用空间网格检测相交横档，并设计算预算。编译器拆分长距离跳针、组织换色并生成唯一结束指令，CLI 写入异常可回滚本次产物。
- **独立可复用：**几何处理、针迹编译、DST 编码及报告生成均以 MoonBit 实现。贡献是可直接集成、可检验的完整编译链；采用既有针法和文件规范，不主张新算法或全球唯一性。

## 三个完整预期使用场景

| 使用者、问题与输入 | 操作、输出与验证 |
|---|---|
| **创客工具的双色徽标。**开发者已有两条折线和线号，需要转为受针长约束的轮廓针迹；<br>输入 `examples/outline.json`。 | CLI 细分路径并编排换色，输出 DST、SVG、JSON：132 个缝制针位、6 跳针、1 换色。自动检查针长和绣框，再用独立 reader 逐条核对坐标与命令。 |
| **不等长双轨的窄缎面。**图案工具作者需要将两条不同长度的边界对应为缎面；<br>输入 `examples/satin.json` 及采样间距。 | 按弧长取站并交替连接，输出 228 个缝制针位、3 跳针及三种文件。检查端点与针长，拒绝回退及导致横档相交的方向错配，文件经独立解码验证。 |
| **带镂空区域的绣章。**教学工具作者需要填充外轮廓并保留孔洞；<br>输入 `examples/patch.json` 的外环、内环和边框。 | 扫描填充后换色描边，输出 2077 个缝制针位、136 跳针、1 换色及三种文件。本例检查孔内无缝制针位，并独立解码核对记录；另以凹形、多孔及嵌套轮廓测试整条缝制线段不穿孔。 |

## 完成情况与可复现验证

已发布 Mooncakes **0.1.0**，公开仓库保留超过十次涉及功能、测试及 CI 的可追溯开发提交，提供 README、输入样例、实际产物及运行命令。Linux CI 的 Wasm、Wasm GC、JavaScript、Native 四个目标各 **11 组测试通过**，Node **10 组测试通过**；编码测试遍历 59049 种合法二维位移。三个案例通过 pyembroidery 1.5.1 独立解码，注册表包已在独立目录下载安装并运行公开 API。

## 原创、参考关系与开源许可

项目为新建实现，采用 **Apache-2.0**。DST 位布局、坐标方向及头部编码参考并改写 [pyembroidery 的 DstWriter.py](https://github.com/EmbroidePy/pyembroidery/blob/815d5febaa005c6afb3ec52235caee51a0111082/pyembroidery/DstWriter.py)，其 **MIT** 许可全文和版权声明已保留于 `docs/pyembroidery-MIT.txt`，根目录 `NOTICE` 记录来源；不是对该项目的整体移植。MoonBit core 为 Apache-2.0；pyembroidery 仅额外用于开发验证；[Ink/Stitch](https://github.com/inkstitch/inkstitch)（GPL-3.0）用于功能比较，未复制其实现或调用其程序。与本人 AgentCanary 等既有项目无核心代码复用，关联和 AI 辅助范围见 `docs/PROVENANCE.md`。

当前三个场景均为合成几何案例，完成了软件互操作验证，尚未机器打样；不包含自动底针、锁针、剪线和拉缩补偿。代码、测试及文档使用 AI 辅助，参赛者对技术解释与结果核验负责。

**公开仓库：**[github.com/zhangbowen2006/NeedleRail](https://github.com/zhangbowen2006/NeedleRail)　 **已发布包：**[zhangbowen2006/needlerail@0.1.0](https://mooncakes.io/docs/zhangbowen2006/needlerail@0.1.0)　 **验证记录：**[GitHub Actions](https://github.com/zhangbowen2006/NeedleRail/actions)
