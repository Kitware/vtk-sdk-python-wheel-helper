
from __future__ import annotations

import os
from .venv import VEnv
from pathlib import Path

import pytest


@pytest.fixture(scope="session")
def curdir() -> Path:
    return Path(__file__).parent.resolve()


@pytest.fixture(scope="session")
def top_level_dir() -> Path:
    return Path(__file__).parent.parent.resolve()


@pytest.fixture(scope="session")
def buildenv(tmp_path_factory: pytest.TempPathFactory, top_level_dir: Path) -> VEnv:
    path = tmp_path_factory.mktemp("cmake_env")
    venv = VEnv(path)
    venv.install("cmake")
    return venv


# return a path suitable for CMAKE_PREFIX_PATH
@pytest.fixture(scope="session")
def dependency(buildenv: VEnv, tmp_path_factory: pytest.TempPathFactory, curdir: Path) -> str:
    # use platform default generator, it may be multiconfig (windows and mac),
    # or single config, so we use both ways to specify build type
    src_dir = (curdir / "Dependency").as_posix()
    build_dir = tmp_path_factory.mktemp("Dependency-build").as_posix()
    buildenv.module(
        "cmake",
        "-S", src_dir,
        "-B", build_dir,
        "-DCMAKE_BUILD_TYPE=Release"
    )

    buildenv.module(
        "cmake",
        "--build", str(build_dir),
        "--config", "Release"
    )

    install_dir = tmp_path_factory.mktemp("Dependency-install")
    buildenv.module(
        "cmake",
        "--install", build_dir,
        "--prefix", install_dir.as_posix(),
        "--config", "Release"
    )

    return (install_dir / "lib" / "cmake" / "Dependency").as_posix()


@pytest.fixture(scope="session")
def wheelhouse(tmp_path_factory: pytest.TempPathFactory) -> Path:
    return tmp_path_factory.mktemp("wheelhouse")


@pytest.fixture(scope="session")
def vtksdk_helper(buildenv: VEnv, top_level_dir: Path, wheelhouse: Path) -> None:
    buildenv.module(
        "pip", "wheel", top_level_dir.as_posix(),
        "--wheel-dir", wheelhouse.as_posix()
    )
    assert list(wheelhouse.glob("vtk_sdk_python_wheel_helper-*.whl"))


@pytest.fixture(scope="session")
def basic_project(buildenv: VEnv, curdir: Path, vtksdk_helper, dependency: str, wheelhouse: Path) -> None:
    os.environ["Dependency_ROOT"] = dependency
    
    basic_project_src = (curdir / "BasicProject").as_posix()
    buildenv.module(
        "pip", "wheel", basic_project_src,
        "--wheel-dir", wheelhouse.as_posix(),
        "--find-links", wheelhouse.as_posix(),
        "--extra-index-url", "https://vtk.org/files/wheel-sdks",
        "--extra-index-url", "https://wheels.vtk.org"
    )
    assert list(wheelhouse.glob("basic_project-*.whl"))


@pytest.fixture(scope="session")
def basic_project_sdk(buildenv: VEnv, curdir: Path, vtksdk_helper, dependency: str, wheelhouse: Path) -> None:
    os.environ["Dependency_ROOT"] = dependency
    
    basic_project_src = (curdir / "BasicProject" / "SDK").as_posix()
    buildenv.module(
        "pip", "wheel", basic_project_src,
        "--wheel-dir", wheelhouse.as_posix(),
        "--find-links", wheelhouse.as_posix(),
        "--extra-index-url", "https://vtk.org/files/wheel-sdks",
        "--extra-index-url", "https://wheels.vtk.org"
    )
    assert list(wheelhouse.glob("basic_project_sdk-*.whl"))


# tmp virtualenv for the test projects
@pytest.fixture()
def virtualenv(tmp_path: Path, top_level_dir: Path) -> VEnv:
    path = tmp_path / "venv"
    return VEnv(path)
