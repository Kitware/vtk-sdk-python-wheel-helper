# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'VTK SDK Python Helper'
copyright = '2026, Kitware SAS'
author = 'Alexy Pellegrini'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinxcontrib.moderncmakedomain']

templates_path = ['_templates']
exclude_patterns = []

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'

# -- CMake Doc Extractor ----------------------------------------------
import os
import re
import textwrap
from pathlib import Path

def extract_cmake_docs(app):
    """
    Searches for .cmake files, extracts #[==[.rst: ... #]==] blocks,
    and generates .rst files for them in the documentation source dir.
    """

    doc_dir = Path(__file__).parent
    rst_output_dir = (doc_dir / 'api').resolve().as_posix()
    if not os.path.exists(rst_output_dir):
        os.makedirs(rst_output_dir)

    # Matches #[==[.rst: (content) #]==] used in CMake code documentation
    doc_pattern = re.compile(r'#\[==\[\.rst:(.*?)#\]==]', re.DOTALL)

    cmake_dir = (doc_dir / ".." / "vtk_sdk_python_wheel_helper").resolve().as_posix()
    for root, _, files in os.walk(cmake_dir):
        for filename in files:
            if filename.endswith('.cmake'):
                filepath = os.path.join(root, filename)

                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Find all rst blocks
                matches = doc_pattern.findall(content)

                if matches:
                    # Create a corresponding .rst file
                    rst_filename = filename.replace('.cmake', '.rst')
                    rst_path = os.path.join(rst_output_dir, rst_filename)

                    with open(rst_path, 'w', encoding='utf-8') as rst_file:
                        # Add a title based on the filename (optional)
                        title = filename
                        rst_file.write(f"{title}\n{'=' * len(title)}\n\n")

                        for match in matches:
                            # Dedent checks for common whitespace indentation and removes it
                            # so Sphinx doesn't think it's a code block.
                            clean_rst = textwrap.dedent(match)
                            rst_file.write(clean_rst + "\n")

def setup(app):
    # Hook the extractor to run before Sphinx reads the sources
    app.connect('builder-inited', extract_cmake_docs)
