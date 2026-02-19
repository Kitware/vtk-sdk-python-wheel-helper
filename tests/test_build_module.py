"""
This creates a venv and does pip install basic_project_sdk in it, then build another project that consummes the sdk
"""

from pathlib import Path
from .venv import VEnv

def test_build_module(virtualenv: VEnv, curdir: Path, top_level_dir: Path, wheelhouse: Path, basic_project, basic_project_sdk):
    test_src = (curdir / "packages" / "build_module").as_posix()
    virtualenv.module(
        "pip", "install", test_src,
        "--find-links", wheelhouse.as_posix(),
        "--find-links", top_level_dir.as_posix(),
        "--extra-index-url", "https://vtk.org/files/wheel-sdks",
        "--extra-index-url", "https://wheels.vtk.org",
        "--verbose"
    )

    virtualenv.execute("from basic_project import vtkDummy; print(vtkDummy()); exit(0)")
    virtualenv.execute("from basic_project_other import vtkOther; print(vtkOther()); exit(0)")
