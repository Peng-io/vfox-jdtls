local http = require("http")
local html = require("html")

local jdtls = {}

jdtls.milestonesUrl = "https://download.eclipse.org/jdtls/milestones/"

local function versionWeight(version)
    local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")
    if major == nil then
        return nil
    end
    return tonumber(major) * 1000000 + tonumber(minor) * 1000 + tonumber(patch)
end

function jdtls.compareVersions(a, b)
    local wa = versionWeight(a)
    local wb = versionWeight(b)
    if wa == nil or wb == nil then
        return a < b
    end
    return wa < wb
end

--- GET 请求，返回响应体；失败时返回 nil 与错误信息
local function get(url, what)
    local resp, err = http.get({ url = url })
    if err ~= nil then
        return nil, what .. "失败: " .. err
    end
    if resp.status_code ~= 200 then
        return nil, what .. "失败: HTTP " .. tostring(resp.status_code)
    end
    return resp.body
end

--- 解析里程碑目录页，返回所有 1.x 版本（升序）
function jdtls.fetchVersions()
    local body, err = get(jdtls.milestonesUrl, "请求版本目录")
    if body == nil then
        return nil, err
    end

    local doc = html.parse(body)
    local versions = {}
    local seen = {}
    doc:find("a"):each(function(_, a)
        local href = a:attr("href")
        local version = href and href:match("/jdtls/milestones/(1%.%d+%.%d+)$")
        if version ~= nil and not seen[version] then
            seen[version] = true
            versions[#versions + 1] = version
        end
    end)

    table.sort(versions, jdtls.compareVersions)
    return versions
end

--- 返回版本的发布目录与文件名
--- 优先读 latest.txt；该版本正在发布时 latest.txt 可能缺失，回退解析目录页
function jdtls.fetchRelease(version)
    local base = jdtls.milestonesUrl .. version .. "/"

    local body = get(base .. "latest.txt", "请求 latest.txt")
    if body ~= nil then
        local name = body:gsub("%s+", "")
        if name:match("%.tar%.gz$") then
            return base, name
        end
    end

    local page, err = get(base, "请求版本目录页")
    if page == nil then
        return nil, nil, err
    end

    local name = nil
    html.parse(page):find("a"):each(function(_, a)
        local href = a:attr("href")
        if href ~= nil then
            local candidate = href:match("([^/]+%.tar%.gz)$")
            if candidate ~= nil then
                name = candidate
            end
        end
    end)

    if name == nil then
        return nil, nil, "未找到 " .. version .. " 的 tar.gz 发布文件"
    end
    return base, name
end

--- 返回发布文件的 SHA256；文件缺失时返回 nil
function jdtls.fetchSha256(base, fileName)
    local body = get(base .. fileName .. ".sha256", "请求校验文件")
    if body == nil then
        return nil
    end
    return body:match("(%x+)")
end

return jdtls
