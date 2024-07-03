package("node-addon-api")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nodejs/node-addon-api")
    set_description("Module for using Node-API from C++")
    set_license("MIT")

    add_configs("errors", {description = "Choose error handling method.", default = "except", type = "string", values = {"except", "noexcept", "maybe"}})
    add_configs("disable_deprecated", {description = "Disable deprecated APIs.", default = true, type = "boolean"})

    set_urls("https://github.com/nodejs/node-addon-api/archive/refs/tags/$(version).tar.gz",
        "https://github.com/nodejs/node-addon-api.git")
    add_versions("v8.0.0", "42424c5206b9d67b41af4fcff5d6e3cb22074168035a03b8467852938a281d47")

    add_deps("nodejs")

    on_load(function(package)
        package:add("defines", "NAPI_VERSION=" .. package:version():major())
        if package:config("disable_deprecated") then
            package:add("defines", "NODE_ADDON_API_DISABLE_DEPRECATED")
        end
        
        local errors = package:config("errors")
        if errors == "noexcept" or errors == "maybe" then
            package:add("cxxflags", "-fno-exceptions")
            package:add("defines", "NAPI_DISABLE_CPP_EXCEPTIONS")
        end
        if errors == "maybe" then
            package:add("defines", "NODE_ADDON_API_ENABLE_MAYBE")
        end
        if errors == "except" then
            package:add("defines", "NAPI_CPP_EXCEPTIONS")
        end
    end)

    on_install("linux" ,function(package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir("include"), "napi.h")))
    end)