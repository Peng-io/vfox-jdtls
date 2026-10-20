local jdtls = require("jdtls")

--- 返回所有可安装的 1.x 版本
--- @param ctx table 空上下文，保留以供后续扩展
--- @return table 版本列表
function PLUGIN:Available(ctx)
    local versions, err = jdtls.fetchVersions()
    if versions == nil then
        error(err)
    end

    local result = {}
    for _, version in ipairs(versions) do
        result[#result + 1] = { version = version }
    end
    return result
end
