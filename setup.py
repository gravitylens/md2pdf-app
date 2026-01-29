from setuptools import setup, find_packages
import os

# Read the long description from README
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

# Get version from __init__.py
version = {}
with open("md2pdf/__init__.py") as fp:
    exec(fp.read(), version)

setup(
    name="md2pdf",
    version=version['__version__'],
    author=version['__author__'],
    description=version['__description__'],
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/jasonniles/md2pdf",
    packages=find_packages(),
    package_data={
        'md2pdf': [],
    },
    include_package_data=True,
    data_files=[
        ('share/md2pdf/templates', ['templates/report-template.typ']),
    ],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Education",
        "Intended Audience :: End Users/Desktop",
        "Topic :: Text Processing :: Markup :: Markdown",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
    entry_points={
        'console_scripts': [
            'md2pdf=md2pdf.cli:main',
        ],
    },
    install_requires=[
        # No Python dependencies - requires system tools
    ],
)
