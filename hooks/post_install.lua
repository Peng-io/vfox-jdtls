local fs = require("fs")

--- 解压 PreInstall 原样落盘的发布包
--- vfox 内置的 tar 解压会剥掉第一层目录，而 JDT.LS 的包顶层直接是 bin/、plugins/、config_*，
--- 剥掉后会摊平并让各平台 config.ini 互相覆盖，因此改用系统 tar。
--- @param ctx table
--- @field ctx.sdkInfo table 按 SDK 名索引的安装信息
function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo["jdtls"]
    if sdkInfo == nil then
        error("未找到 jdtls 的安装信息")
    end

    local installPath = sdkInfo.path
    local isWindows = string.lower(RUNTIME.osType or "") == "windows"

    --- 路径来自安装目录而非外部输入，但它会被拼进 shell 命令，仍需排除元字符
    if isWindows then
        if installPath:find('[&|<>^%%()!"]') ~= nil or installPath:find(" ") ~= nil then
            error("安装路径包含不支持的字符: " .. installPath)
        end
    elseif installPath:find('[%$`"\\]') ~= nil then
        error("安装路径包含不支持的字符: " .. installPath)
    end

    local cmd
    if isWindows then
        --- vfox 通过 SysProcAttr.CmdLine 原样传命令，cmd 不会剥离双引号，
        --- 引号会被 tar 当成文件名的一部分，所以这里刻意不加引号。
        --- 必须用 System32 的原生 tar：Git 附带的 MSYS tar 会把盘符路径二次转义
        cmd = string.format("%%SystemRoot%%\\System32\\tar.exe -xzf %s\\jdtls.bin -C %s", installPath, installPath)
    else
        cmd = string.format('tar -xzf "%s/jdtls.bin" -C "%s"', installPath, installPath)
    end

    if os.execute(cmd) ~= 0 then
        error("解压失败，请确认系统 tar 可用: " .. cmd)
    end

    fs.remove(installPath .. "/jdtls.bin")
end
