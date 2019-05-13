# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
load(
    "//kotlin/internal:defs.bzl",
    _KT_COMPILER_REPO = "KT_COMPILER_REPO",
    _KtJsInfo = "KtJsInfo",
    _TOOLCHAIN_TYPE = "TOOLCHAIN_TYPE",
)
load(
    "//kotlin/internal/js:impl.bzl",
    _kt_js_import_impl = "kt_js_import_impl",
    _kt_js_library_impl = "kt_js_library_impl",
)

_JS_STDLIB_MAP = {
    "kotlin-stdlib-js": "kotlin",
    "kotlin-test-js": "kotlin-test",
}

# The macro, and the ones using it exist to ensure compatibility with the nodejs rules, the nodejs rules process the
# attributes and not the providers. Ideally providers would be used so the rules can pass the information along without
# having to have user facing attributes visible.
#   module_root: if the module_root is made settable then there is a possibility of collisions. Keeping it simple here.
#   module_name: The require statement generated by Kotlinc-js seems to be based on the name of the jar. Unlike the jvm
#       compiler, there is no 'module-name' flag available. So to keep things simple it's hard coded to the module name.
def _lock_attrs(name, kwargs):
    if native.repository_name().startswith("@") and native.repository_name().endswith(_KT_COMPILER_REPO):
        name = _JS_STDLIB_MAP.get(name, default = name)
    if kwargs.get("module_root") != None:
        fail("The module_root is an internal attribute.")
    else:
        kwargs["module_root"] = name + ".js"
    if kwargs.get("module_name") != None:
        fail("module_name is an internal attribute.")
    else:
        kwargs["module_name"] = name
    return kwargs

kt_js_library = rule(
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            allow_files = [".kt"],
            mandatory = True,
        ),
        "data": attr.label_list(
            allow_files = True,
            default = [],
            cfg = "target",
        ),
        "deps": attr.label_list(
            doc = """A list of other kotlin JS libraries.""",
            default = [],
            allow_empty = True,
            providers = [_KtJsInfo],
        ),
        "runtime_deps": attr.label_list(
            doc = """A list of other kotlin JS libraries that should be available at runtime.""",
            default = [],
            allow_empty = True,
            providers = [_KtJsInfo],
        ),
        "module_kind": attr.string(
            doc = """The Kind of a module generated by compiler, users should stick to commonjs.""",
            default = "commonjs",
            values = ["umd", "commonjs", "amd", "plain"],
        ),
        "js_target": attr.string(
            default = "v5",
            values = ["v5"],
        ),
        "module_root": attr.string(
            doc = "internal attriubte",
            mandatory = False,
        ),
        "module_name": attr.string(
            doc = "internal attribute",
            mandatory = False,
        ),
        "_toolchain": attr.label(
            doc = """The Kotlin JS Runtime.""",
            default = Label("@" + _KT_COMPILER_REPO + "//:kotlin-stdlib-js"),
            cfg = "target",
        ),
    },
    implementation = _kt_js_library_impl,
    outputs = dict(
        js = "%{name}.js",
        js_map = "%{name}.js.map",
        jar = "%{name}.jar",
        srcjar = "%{name}-sources.jar",
    ),
    toolchains = [_TOOLCHAIN_TYPE],
    provides = [_KtJsInfo],
)

def kt_js_library_macro(name, **kwargs):
    kwargs = _lock_attrs(name, kwargs)

    # TODO this is a runtime dep, it should be picked up from the _toolchain attr or from a provider.
    kwargs["deps"] = kwargs.get("deps", []) + ["@" + _KT_COMPILER_REPO + "//:kotlin-stdlib-js"]
    kt_js_library(name = name, **kwargs)

kt_js_import = rule(
    attrs = {
        "jars": attr.label_list(
            allow_files = [".jar"],
            mandatory = True,
        ),
        "srcjar": attr.label(
            mandatory = False,
            allow_single_file = ["-sources.jar"],
        ),
        "runtime_deps": attr.label_list(
            default = [],
            allow_files = [".jar"],
            mandatory = False,
        ),
        "module_name": attr.string(
            doc = "internal attribute",
            mandatory = False,
        ),
        "module_root": attr.string(
            doc = "internal attriubte",
            mandatory = False,
        ),
        "_importer": attr.label(
            default = "//kotlin/internal/js:importer",
            allow_files = True,
            executable = True,
            cfg = "host",
        ),
    },
    outputs = dict(
        js = "%{module_name}.js",
        js_map = "%{module_name}.js.map",
    ),
    implementation = _kt_js_import_impl,
    provides = [_KtJsInfo],
)

def kt_js_import_macro(name, **kwargs):
    kwargs = _lock_attrs(name, kwargs)
    kt_js_import(name = name, **kwargs)
