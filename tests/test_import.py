"""
This creates a venv and does pip install BasicProject in it, then call a few python scripts
"""

from pathlib import Path
from .venv import VEnv

def test_import(virtualenv: VEnv, top_level_dir: Path, wheelhouse: Path, basic_project):
    virtualenv.module("pip", "install", "basic-project",
        "--find-links", wheelhouse.as_posix(), 
        "--find-links", top_level_dir.as_posix(), 
        "--extra-index-url", "https://vtk.org/files/wheel-sdks",
        "--extra-index-url", "https://wheels.vtk.org"
    )

    virtualenv.execute("from basic_project import vtkDummy; print(vtkDummy()); exit(0)")
    virtualenv.execute("import basic_project; exit(int(hasattr(basic_project, 'vtkmodules')))")
    virtualenv.execute("import basic_project; from pathlib import Path; exit(0 if sum(1 for f in Path(basic_project.__path__[0] + '/third_party.libs').iterdir() if f.is_file()) == 1 else 1)")
