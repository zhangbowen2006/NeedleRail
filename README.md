# NeedleRail

公开仓库：[zhangbowen2006/NeedleRail](https://github.com/zhangbowen2006/NeedleRail)。经终端核验并获得本人确认，本次使用旧账号 zhangbowen2006 发布，未使用此前提出但未核验的新账号。

**将明确的几何图案编译成机器刺绣针迹、Tajima DST 文件与 SVG 预览。** 核心使用 MoonBit，不调用 Ink/Stitch、Python 或云服务完成生产计算；Node CLI 只负责文件读写。

独立工具与可复用库，服务于创客空间、简单绣章设计、教学与程序生成图案。输入是折线、双轨或多边形，输出是针位与实际文件，不从照片猜测针迹。三种针法和文件格式都是已有技术，本项目不声称发明针法或全球唯一。[竞品调查](docs/RESEARCH.md) · [来源与旧账号披露](docs/PROVENANCE.md) · [验证记录](docs/VALIDATION.md)。

## 五分钟运行

需要 [MoonBit 工具链](https://www.moonbitlang.com/download/) 和 Node.js 22+。本次验证工具链为 `moon 0.1.20261028`，core `0.10.18+6c83a7f62`，Node.js 24.22.1。

```sh
moon check --deny-warn
moon test --deny-warn
moon run cmd/main
moon build --target js --release --deny-warn
node scripts/cli.mjs examples/outline.json generated/outline
node scripts/cli.mjs examples/satin.json generated/satin
node scripts/cli.mjs examples/patch.json generated/patch
node --test tests/*.test.mjs
```

每次生成 `.dst`、`.svg`、`.json`。CLI 拒绝覆盖已有输出；改用新前缀即可。成功退出 0，输入、编译或文件错误退出 2。提交的 [outputs](outputs) 是真实生成的三个样例，不需要安装工具链即可查看 SVG 和报告。

本机尚未全局配置 MoonBit 时，PowerShell 可临时设置：

```powershell
$env:MOON_HOME='D:\CodexProjects\.tools\moon'
$env:PATH="$env:MOON_HOME\bin;$env:PATH"
Set-Location .\NeedleRail
```

## 三个完整场景

| 使用者与问题 | 输入、操作与输出 | 验证方式 |
|---|---|---|
| 创客空间人员希望把程序生成徽标轮廓交给刺绣软件 | `outline.json` 的两条彩色折线，经 CLI 输出 DST、预览和报告 | 132 个缝制针位、6 跳针、1 换色；外部解码逐条核对 |
| 图案作者需要沿两条有不同几何长度的边界生成窄缎面 | `satin.json` 的双轨，按弧长重采样并交替缝制 | 222 个缝制针位、3 跳针；检查步长及端点，超宽或交叉轨道报错 |
| 绣章教学人员需要带孔填充，避免针迹跨过镂空区域 | `patch.json` 的外轮廓与内孔，扫描填充后再缝制边框 | 2077 个缝制针位、136 跳针、1 换色；孔内无缝制点，断开区间使用跳针，DST 外部解码一致 |

以上均为合成几何，未采集第三方图案。针位计数包含每个独立区间起点的零位移落针。没有做真实机器打样；外部解码通过不等于所有设备兼容或布料效果合格。

## 输入与库接口

所有数值坐标均为 **0.1 mm 整数**。`width`、`height` 为居中矩形绣框的完整宽高，`max_step` 是缝制的最大欧氏步长。

```json
{
  "width": 1000, "height": 1000, "max_step": 25,
  "objects": [
    {"kind":"running","thread":0,"path":[[0,0],[100,100],[200,0]]}
  ]
}
```

- `running`：提供 `path`，保留拐点并细分长线。
- `satin`：提供 `left`、`right`、`spacing`。两轨方向应对应；按各轨归一化弧长取点，交替连接。超过最大针长时失败，不改成其他针法。
- `fill`：提供 `rings`、`spacing`。每环不重复首点；环须简单、互不相交或接触，以奇偶规则处理孔与嵌套。只支持水平扫描，不自动旋转纹理。
- `thread` 为 0–63 的调用方线序标识。物件按输入顺序缝制，线号变化生成换色命令。DST 不保存 RGB；SVG 用固定循环调色板示意，JSON 保留线号。

在消费包 `moon.pkg` 导入 `"zhangbowen2006/needlerail" @rail` 后，可调用 `running`、`satin`、`fill` 或 `compile`，再通过 `Plan::dst`、`svg`、`report` 输出。[生成接口](pkg.generated.mbti) 为当前签名依据。`parse_job` 返回结构化 Result 错误，`compile_json` 返回纯 JSON。包未发布前不能声称注册表安装已可用。

## 算法与边界

折线细分为整数针位，并为舍入留出余量。缎面使用两轨弧长采样；填充采用半开边扫描交点、排序、奇偶配对及蛇形行序，孔两侧分成独立 spans。编译器验证绣框、拆分远距离跳针、显式换色并添加唯一结束指令。DST 使用平衡三进制位布局、512 字节头部及三字节记录，屏幕 y 向下，编码时翻转 DST y。

限制：1–256 个物件，坐标绝对值不超过 10000 单位；绣框宽高 100–10000；max_step 3–121。每条折线最多 10000 点，缎面每轨最多 512 点，填充 1–16 环、每环 3–512 点、合计最多 2048 边；总指令最多 200000。JSON 最多 4000000 个 UTF-16 单元、16 层嵌套，拒绝小数坐标、未知字段和重复键。

没有照片自动数字化、字体排版、自动底针、锁针、剪线命令、拉缩补偿、布料模型、机器控制或其他厂商格式。分区间跳针不会自动剪线，实际制作者需要在线路连接与机型设置上做判断。预览展示几何路径，不模拟线密度、布面变形或成品质量。

## 验证、来源与许可

本机严格检查所有四个目标通过；Wasm、Wasm GC、JavaScript 各 7 组 MoonBit 测试通过。测试遍历 59049 个合法二维 DST 位移，分别验证缝制与跳针。Node 4 组集成测试通过。三个文件经 pyembroidery 1.5.1 独立解码，全部位置、命令与头部边界一致，SVG 通过 XML 解析。原生运行因本机缺少 MSVC Build Tools 未完成。

可选独立复核：安装 `pyembroidery==1.5.1` 后运行 `python scripts/verify_dst.py`。Python 只用于外部测试。[远端 CI 已通过](https://github.com/zhangbowen2006/NeedleRail/actions/runs/41015738042)，Linux 上四个目标各 7 组测试通过，包括 Native；CLI 测试及重新生成文件的外部解码也通过。Windows 本机仍缺少原生编译工具，不能将 Linux 结果解释为 Windows Native 运行通过。

Apache-2.0。DST 位布局与头部参考了 MIT 许可的 pyembroidery，保留 [MIT 声明](docs/pyembroidery-MIT.txt)；不是 Ink/Stitch 的封装，没有复制其 GPL 实现。AI 参与开发与工程文档，正式比赛申报正文由参赛者本人独立完成。
