--- !!! DO NOT EDIT OR RENAME !!!
PLUGIN = {}

PLUGIN.name = "jdtls"
PLUGIN.version = "0.1.1"
PLUGIN.homepage = "https://github.com/Peng-io/vfox-jdtls"
PLUGIN.license = "Apache 2.0"
PLUGIN.description = "Eclipse JDT Language Server (Java LSP)"

--- 需要 http.get 与 html.parse
PLUGIN.minRuntimeVersion = "0.4.0"

PLUGIN.manifestUrl = "https://github.com/Peng-io/vfox-jdtls/releases/download/manifest/manifest.json"

PLUGIN.legacyFilenames = {}
PLUGIN.notes = {
    "运行 JDK：1.61.0 及以前需 17+，1.62.0 起需 25",
    "另需 Python 3.9+（jdtls 启动脚本是 Python wrapper）",
}
