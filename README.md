# vfox-jdtls

用 vfox 管理 [Eclipse JDT Language Server](https://github.com/eclipse-jdtls/eclipse.jdt.ls)（Java LSP）的版本。

安装后 `bin` 目录会进入 `PATH`，可直接被 Claude Code 的 `jdtls-lsp` 插件或其他 LSP 客户端使用。

## 依赖

- Java：最低版本随 JDT.LS 版本变化，见下方对照表。这里指语言服务器自身运行所需，不是项目 JDK。
- Python 3.9 或更高版本（`bin/jdtls` 是 Python 启动脚本）

### JDK 适配对照

| JDT.LS 版本 | 最低运行 JDK |
|---|---:|
| 1.0.0 | 8 |
| 1.10.0 – 1.20.0 | 11 |
| 1.30.0 – 1.61.0 | 17 |
| 1.62.0 – 1.63.0 | 25 |

最低 JDK 读取自各版本 `org.eclipse.core.filesystem` 清单的 `Bundle-RequiredExecutionEnvironment`。1.62.0 起该 bundle 跳到 JavaSE-25，Java 21 环境请使用 1.61.0 或更早。官方 README 仍写 Java 21 最低，已滞后。

## 实现约束

- vfox 内置的 tar 解压会剥掉压缩包的第一层目录。JDT.LS 的包顶层直接是 `bin/`、`plugins/`、`config_*`，剥掉后会摊平并让各平台 `config.ini` 互相覆盖。因此 `PreInstall` 用 URL fragment 把包伪装成 `jdtls.bin`，让 vfox 原样落盘，再由 `PostInstall` 调用系统 tar 解压。
- Windows 必须用 `%SystemRoot%\System32\tar.exe`：Git 附带的 MSYS tar 会把盘符路径二次转义（`X:\` 变成 `X\:\\`），导致找不到文件。
- vfox 通过 `SysProcAttr.CmdLine` 原样传命令，cmd 不剥离双引号，引号会被 tar 当成文件名的一部分。因此 Windows 分支不使用引号，安装路径不能含空格。

## 安装插件

从本仓库源码目录安装：

```bash
vfox add --source .
```

发布后也可以从 [Releases](https://github.com/Peng-io/vfox-jdtls/releases) 下载 zip，再执行：

```bash
vfox add --source <zip 文件路径>
```

## 使用

```bash
vfox search jdtls                 # 列出 1.x 版本
vfox install jdtls@1.61.0
vfox use jdtls@1.61.0             # 当前 shell
```

安装后确认命令可达：

```bash
jdtls --help
```

## 在 Claude Code 中启用

1. 先按 [Code intelligence plugins](https://code.claude.com/docs/en/plugins/code-intelligence) 安装插件：

   ```
   /plugin install jdtls-lsp@claude-plugins-official
   ```

2. 确认 `jdtls` 在启动 `claude` 的 shell 的 `PATH` 中（`vfox use` 之后启动新会话）。

3. 让 Claude 编辑一个 `.java` 文件，出现 `Found N new diagnostic issues` 即表示服务器已启动。

## 版本范围

`Available` 只返回 `1.x` 版本（`1.0.0` 起）。`0.x` 未纳入：版本过旧，且未针对现行 LSP 客户端验证。

## 校验

`PreInstall` 会读取发布目录中的 `.sha256` 文件并交给 vfox 校验；该文件缺失时跳过校验。

## 测试

需要支持 `vfox plugin` 子命令的 vfox 版本：

```bash
vfox plugin test .
vfox plugin run . PreInstall --input '{"version":"1.61.0"}' --json
```
