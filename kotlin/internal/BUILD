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
load("//kotlin/internal:toolchains.bzl", "define_kt_toolchain")

config_setting(
    name = "builder_debug_timings",
    values = {"define": "kt_timings=1"},
)

config_setting(
    name = "builder_debug_trace",
    values = {"define": "kt_trace=1"},
)

toolchain_type(
    name = "kt_toolchain_type",
    visibility = ["//visibility:public"],
)

define_kt_toolchain(
    name = "default_toolchain",
    coroutines = None
)
