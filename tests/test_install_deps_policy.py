from pathlib import Path


def test_install_deps_sets_cmp0207_before_runtime_dependency_scan(
    top_level_dir: Path,
):
    template = (
        top_level_dir
        / "vtk_sdk_python_wheel_helper"
        / "install-deps.cmake.in"
    ).read_text(encoding="utf-8")

    policy_position = template.index("cmake_policy(SET CMP0207 NEW)")
    runtime_deps_position = template.index("file(GET_RUNTIME_DEPENDENCIES")

    assert "if(POLICY CMP0207)" in template
    assert policy_position < runtime_deps_position
