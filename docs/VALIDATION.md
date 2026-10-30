# 实际验证记录

日期：北京时间 2026-10-30。工作目录：D:\CodexProjects\NeedleRail。仅本项目记录，不继承此前撤回试验的结果。

按本人后续要求，当前工作副本改为 D:\Backup\Documents\ChatGPT\张博文\NeedleRail，通过公开仓库重新检出，保留同一历史与 main 分支。该中文路径下重新完成四目标严格检查、Wasm/Wasm GC/JS 各 7 组测试、4 组 Node 集成测试及 patch 文件生成；生成 DST 的 SHA256 与已提交产物一致。新检出的 CRLF 导致格式检查失败，补充 .gitattributes 并规范为 LF 后，moon info、moon fmt、moon fmt --check 通过；没有修改 DST 二进制。

工具链：moon 0.1.20261028 (e1e1f15)、moonc v0.10.18+6c83a7f62、Node.js v24.22.1。工具链 ZIP 的 SHA256 与官方发布校验值一致。MoonBit 安装在 D:\CodexProjects\.tools\moon，非全局安装。

| 命令 | 实际结果 |
|---|---|
| `moon check --target all --deny-warn` | 通过，包括 native 类型检查；不是四目标运行通过 |
| `moon test --target wasm --deny-warn` | 11 组通过，0 失败 |
| `moon test --target wasm-gc --deny-warn` | 11 组通过，0 失败 |
| `moon test --target js --deny-warn` | 11 组通过，0 失败 |
| `moon build --target wasm --deny-warn` | 通过 |
| `moon build --target wasm-gc --deny-warn` | 通过 |
| `moon build --target js --release --deny-warn` | 通过，生成 bridge.js 和 cmd/main |
| `moon test --target native --deny-warn` | 未完成；工具报告缺少 MSVC C++ 工具与 Windows SDK，没有把它写成通过 |
| `node --test tests/*.test.mjs` | 10 组通过，0 失败，覆盖三个文件工作流、范围约束、拒绝覆盖与无效输入 |
| `node scripts/cli.mjs examples/outline.json outputs/outline` | 生成 132 个缝制针位、6 跳针、1 换色；140 条 DST 记录 |
| `node scripts/cli.mjs examples/satin.json outputs/satin` | 生成 228 个缝制针位、3 跳针、0 换色；232 条记录 |
| `node scripts/cli.mjs examples/patch.json outputs/patch` | 生成 2077 个缝制针位、136 跳针、1 换色；2215 条记录 |
| `python scripts/verify_dst.py`，环境含 pyembroidery 1.5.1 | 三个案例全部位置、命令、记录数和头部边界一致；SVG 通过 XML 解析，报告见 dst-verification.json |
| `moon publish --dry-run` | 失败，Registry login is required；不代表包已发布，不能用猜测的包链接作为发布证据 |
| `moon run cmd/main` | 通过，打印实际指令报告与 560 字节 DST 长度 |
| `moon package --list` | 检查通过并生成本地发布包；警告 repository 为空，因为公开仓库尚未创建，不填虚构地址 |

DST 核心测试遍历 dx/dy=-121..121 的 59049 种组合，对 Stitch 和 Jump 分别用直接位权求和解码。几何测试覆盖保留拐点、针长、退化输入、轨道相交、带孔填充、自交/重复环、边回退、绣框与唯一结束指令。API 拒绝小数坐标、非法针法及类型，JSON 解析拒绝重复键和未知字段。

Node 测试将当前编译结果与已提交 DST/JSON/SVG 逐项比对。CI 将重新生成三份文件，再通过独立 Python reader 检查，避免只验证历史产物。

后续远端验证：公开仓库 [zhangbowen2006/NeedleRail](https://github.com/zhangbowen2006/NeedleRail)，默认分支 main。已核验首次远端 HEAD 为 fbeb6f50669fd353faf31b3eeb835c5ab3124dfa，与本地一致。[Actions 41015738042](https://github.com/zhangbowen2006/NeedleRail/actions/runs/41015738042) 全部成功：Linux 上四个目标检查、构建、各 7 组测试均通过，CLI 与当前提交样例回归通过，重新生成的三份 DST/SVG 经独立 reader/XML 解析通过。GitHub API 将提交作者与提交者均识别为 zhangbowen2006。

局限：XML 解析不是完整视觉审查；外部 reader 通过不是通用机型认证。未真实刺绣、未验证剪线行为与布料成品、未做跨平台性能基准或用户部署。Linux Native 通过不代表 Windows Native 本机运行通过。

GitHub 身份、公开默认分支与 CI 已核验。Mooncakes 仍需本人在终端完成登录，包页面尚未发布；报名次数、资格和人工申报未验证。

最新子代理复核整合后，重新执行上述三后端测试（各11组）、Node测试（10组）及外部解码全部通过，详见 REVIEW-20261030.md。此前远端CI链接对应旧版7组测试，不代表新提交已经远端通过；新提交须查看其关联Actions结果。

新版本远端已核验：[Actions 41067104221](https://github.com/zhangbowen2006/NeedleRail/actions/runs/41067104221) 对应 c750f52，四目标各11组、Node10组及独立解码全部通过。
