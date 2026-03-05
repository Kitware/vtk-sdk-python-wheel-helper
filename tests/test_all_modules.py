"""
This creates a venv and does pip install basic_project_sdk in it, then build another project that consummes the sdk
"""

from pathlib import Path
from .venv import VEnv

def test_all_modules(virtualenv: VEnv, curdir: Path, wheelhouse: Path):
    all_modules_src = (curdir / "packages" / "all_modules").as_posix()
    virtualenv.module(
        "pip", "install", all_modules_src,
        "--find-links", wheelhouse.as_posix(),
        "--no-index",
        "--verbose"
    )
    
    virtualenv.execute("from all_modules import vtkDummy; print(vtkDummy()); exit(0)")
