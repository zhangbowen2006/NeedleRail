# 0.1.0 发布证据

- 实际发布账号：zhangbowen2006，moon whoami 已核验。
- 注册表时间：2026-10-30T16:05:14.789788Z，即北京时间 2026-10-31 00:05:14。
- 包：[zhangbowen2006/needlerail@0.1.0](https://mooncakes.io/docs/zhangbowen2006/needlerail@0.1.0)。
- 发布源码：[v0.1.0](https://github.com/zhangbowen2006/NeedleRail/tree/v0.1.0)，指向 cc5e84a880a92f97c87971249e927b422e95ae2c。
- 该提交的 [CI 全部通过](https://github.com/zhangbowen2006/NeedleRail/actions/runs/41067319802)。
- 发布包 SHA256：80c28cb018250c83076e4142c6a15ab90f7f13a540fadc02cf86b6d2d1f128d7；本地上传归档与 moon view 返回的 checksum 一致。

实际操作与结果：

1. `moon publish --dry-run`：本项目检查、打包后解压检查通过，服务端 202 Accepted。
2. `moon publish`：同样通过检查，服务端 200 OK。
3. `moon view zhangbowen2006/needlerail@0.1.0 --json`：返回精确版本 0.1.0、非撤回状态和上述 checksum；moon search 也能检出。
4. 在项目目录外的新建临时模块执行 `moon add zhangbowen2006/needlerail@0.1.0`：实际从注册表下载成功。消费模块导入包，调用公开 compile/commands/dst API。输入 [0,0] 到 [100,0]，max_step=25；断言 7 条指令与 533 字节 DST 后运行成功，输出 `Published package OK: 6 needle points, DST 533 bytes`。
5. 包文档 URL 返回 HTTP 200。

发布后的 GitHub 提交仅更新文档与发布状态，不增加核心功能、测试数量或另发文档补丁版本。0.1.0 归档保留发布时的内容，源码标签可追溯。没有将注册表下载安装产生的下载数视为外部用户采用证据。

发布成功不等于报名、初审或验收通过。正式一页申报已按参赛者确认的AI许可口径制作，见 SUBMISSION.md；报名次数、资格和本人核对提交仍须处理，没有机器打样或真实用户反馈。
