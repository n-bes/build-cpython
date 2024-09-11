#!/usr/bin/env python3
import enum
import os
from jinja2 import Template, StrictUndefined
from itertools import product


@enum.unique
class Platforms(enum.Enum):
    amd64 = "amd64"
    arm64 = "arm64"


@enum.unique
class BaseImages(enum.Enum):
    fedora = "nbesdev/build-cpython:fedora"
    ubuntu = "nbesdev/build-cpython:ubuntu"


@enum.unique
class PythonVersions(enum.Enum):
    py_3_12_4 = "3.12.4"
    py_3_13_0_b4 = "3.13.0b4"


@enum.unique
class Compilers(enum.Enum):
    gcc = "gcc"
    clang_os = "clang"
    clang_sh_19 = "clang_sh_19"


@enum.unique
class CompilerOptions(enum.Enum):
    none = "none"
    asan = "asan"
    tsan = "tsan"
    hwasan = "hwasan"
    analyzer = "analyzer"


@enum.unique
class ClangHWasanAdditionalOptions(enum.Enum):
    none = "none"
    disable_globals = "-mllvm -hwasan-globals=0"


@enum.unique
class SanLinksMethods(enum.Enum):
    none = "none"
    shared = "shared"
    static = "static"


@enum.unique
class LDPreloadModes(enum.Enum):
    enabled = "enabled"
    disabled = "disabled"


@enum.unique
class BuildOptions(enum.Enum):
    debug = "debug"
    default = "default"
    release = "release"
    without_git = "without_git"


print(
    "script_name",
    "Platform",
    "BaseImage",
    "PythonVersion",
    "Compiler",
    "CompilerOption",
    "SanLinksMethod",
    "LDPreloadMode",
    "BuildOption",
    "ClangHWasanAdditionalOption",
    sep=','
)

configurations = []

with open("build.sh.j2", encoding="utf8") as template_file:
    template = Template(template_file.read(), undefined=StrictUndefined)

    counter = 0
    for (
            Platform,
            BaseImage,
            PythonVersion,
            Compiler,
            CompilerOption,
            SanLinksMethod,
            LDPreloadMode,
            BuildOption,
            ClangHWasanAdditionalOption
    ) in product(
        Platforms,
        BaseImages,
        PythonVersions,
        Compilers,
        CompilerOptions,
        SanLinksMethods,
        LDPreloadModes,
        BuildOptions,
        ClangHWasanAdditionalOptions
    ):
        # llvm.sh is not supported on fedora
        if all([
            (BaseImage == BaseImages.fedora),
            (Compiler == Compilers.clang_sh_19)
        ]):
            continue

        # clang analyzer is not setup yet
        if all([
            (Compiler != Compilers.gcc),
            (CompilerOption == CompilerOptions.analyzer)
        ]):
            continue

        # use SanLinksMethods only on asan/hwasan/tsan
        if all([
            (CompilerOption in [CompilerOptions.asan, CompilerOptions.hwasan, CompilerOptions.tsan]),
            (SanLinksMethod == SanLinksMethods.none)
        ]):
            continue

        if all([
            (CompilerOption not in [CompilerOptions.asan, CompilerOptions.hwasan, CompilerOptions.tsan]),
            (SanLinksMethod != SanLinksMethods.none)
        ]):
            continue


        # enable ld_preload only with ASAN/HWASAN
        # todo: libtsan.so
        if all([
            (CompilerOption not in [CompilerOptions.asan, CompilerOptions.hwasan]),
            (LDPreloadMode == LDPreloadModes.enabled)
        ]):
            continue

        # use HWASAN options only with clang and enabled hwasan
        if all([
            (Compiler == Compilers.gcc),
            (ClangHWasanAdditionalOption != ClangHWasanAdditionalOptions.none)
        ]):
            continue

        if all([
            (Compiler != Compilers.gcc),
            (CompilerOption != CompilerOptions.hwasan),
            (ClangHWasanAdditionalOption != ClangHWasanAdditionalOptions.none)
        ]):
            continue

        # without git available only on python 3.13+
        if all([
            (PythonVersion == PythonVersions.py_3_12_4),
            (BuildOption == BuildOptions.without_git)
        ]):
            continue

        # Runtime issues:
        if Platform == Platforms.arm64:
            continue
        if CompilerOption == CompilerOptions.hwasan:
            continue

        # if counter == 10:
        # 	break

        counter += 1
        counter_str = str(counter).zfill(3)

        if not os.path.exists("build_scripts"):
            os.makedirs("build_scripts")
        script_name = f"build_{counter_str}.sh"

        configurations.append({
            "image": f"{BaseImage.value}-{Platform.value}",
            "build_script": script_name,
        })

        with open(
            f"build_scripts/{script_name}",
            "w", encoding="utf8",
        ) as render_file:
            script_content = template.render(
                Platforms=Platforms,
                BaseImages=BaseImages,
                PythonVersions=PythonVersions,
                Compilers=Compilers,
                CompilerOptions=CompilerOptions,
                SanLinksMethods=SanLinksMethods,
                LDPreloadModes=LDPreloadModes,
                BuildOptions=BuildOptions,
                ClangHWasanAdditionalOptions=ClangHWasanAdditionalOptions,

                Platform=Platform,
                BaseImage=BaseImage,
                PythonVersion=PythonVersion,
                Compiler=Compiler,
                CompilerOption=CompilerOption,
                SanLinksMethod=SanLinksMethod,
                LDPreloadMode=LDPreloadMode,
                BuildOption=BuildOption,
                ClangHWasanAdditionalOption=ClangHWasanAdditionalOption
            )

            strip_lines = False
            for line in script_content.splitlines():
                if line == "# strip_lines: True":
                    strip_lines = True
                    continue
                if line == "# strip_lines: False":
                    strip_lines = False
                    continue
                if strip_lines:
                    line = line.strip()
                if line:
                    render_file.write(line)
                    render_file.write("\n")

        print(
            script_name,
            Platform.value,
            BaseImage.value,
            PythonVersion.value,
            Compiler.value,
            CompilerOption.value,
            SanLinksMethod.value,
            LDPreloadMode.value,
            BuildOption.value,
            ClangHWasanAdditionalOption.value,
            sep=','
        )
        os.chmod(f"build_scripts/{script_name}", 0o744)

with open("workflow.yaml.j2", encoding="utf8") as wft_file:
    wf_template = Template(wft_file.read())
    with open("workflow.yaml", "w", encoding="utf8") as wf_file:
        wf_file.write(
            wf_template.render(configurations=configurations)
        )

for name in ["kube_logs.sh", "argo_logs.sh"]:
    with open(f"{name}.j2", encoding="utf8") as lt_file:
        l_template = Template(lt_file.read())
        with open(name, "w", encoding="utf8") as l_file:
            l_file.write(
                l_template.render(configurations=configurations)
            )
    os.chmod(name, 0o744)
