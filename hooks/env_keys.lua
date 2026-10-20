--- 把 jdtls 的启动脚本目录加入 PATH
--- @param ctx table
--- @field ctx.path string SDK 安装目录
function PLUGIN:EnvKeys(ctx)
    return {
        {
            key = "PATH",
            value = ctx.path .. "/bin",
        },
    }
end
