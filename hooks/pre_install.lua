local jdtls = require("jdtls")

--- 返回指定版本的下载地址与校验值
--- @param ctx table
--- @field ctx.version string 用户输入的版本
--- @return table
function PLUGIN:PreInstall(ctx)
    local version = ctx.version

    if version == nil or version == "" or version == "latest" then
        local versions, err = jdtls.fetchVersions()
        if versions == nil then
            error(err)
        end
        version = versions[#versions]
    end

    --- 只允许 1.x.y，避免把任意输入拼进下载地址
    if not version:match("^1%.%d+%.%d+$") then
        error("不支持的版本: " .. tostring(version))
    end

    local base, fileName, err = jdtls.fetchRelease(version)
    if base == nil then
        error(err)
    end

    --- vfox 解压 tar 时会剥掉第一层目录，破坏 JDT.LS 的 bin/plugins/config_* 结构。
    --- 用 fragment 把文件名伪装成 .bin，让 vfox 原样落盘，交给 PostInstall 解压。
    local result = {
        version = version,
        url = base .. fileName .. "#/jdtls.bin",
    }

    --- 缺少校验文件时拒绝安装：无法验证下载内容完整性
    local sha256 = jdtls.fetchSha256(base, fileName)
    if sha256 == nil then
        error("无法获取校验文件: " .. base .. fileName .. ".sha256")
    end
    result.sha256 = sha256

    return result
end
