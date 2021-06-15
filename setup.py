import re
import os
import platform
from setuptools import setup, Extension, find_packages

import numpy as np

extra_compile_args = []
if platform.system().lower() == 'windows':
    # This may fail if compiled on Windows with a compiler
    # that doesn't provide a cl.exe compatability frontend
    # like mingw
    extra_compile_args = ['/EHsc']


try:
    from Cython.Build import cythonize
    ext_modules = [
        Extension(
            "pynumpress.pynumpress", [
                os.path.join('pynumpress/pynumpress.pyx'),
                os.path.join('pynumpress/MSNumpress.cpp'),
            ],
            language='c++',
            extra_compile_args=extra_compile_args,
            include_dirs=[np.get_include()]
        )
    ]
    ext_modules = cythonize(ext_modules)
except ImportError:
    ext_modules = [
        Extension(
            "pynumpress.pynumpress", [
                os.path.join('pynumpress/pynumpress.cpp'),
                os.path.join('pynumpress/MSNumpress.cpp'),
            ],
            language='c++',
            extra_compile_args=extra_compile_args,
            include_dirs=[np.get_include()]
        )
    ]

with open("pynumpress/version.py") as version_file:
    version = None
    for line in version_file.readlines():
        if "version = " in line:
            match = re.search(r"version\s*=\s*['\"]([^'\"]+)['\"]", line.strip())
            if match:
                version = match.group(1)
                print("Version is: %r" % (version,))
                break
    else:
        print("Cannot determine version")

setup(
    name="pynumpress",
    packages=find_packages(),
    version=version,
    install_requires=['numpy'],
    include_dirs=[np.get_include()],
    ext_modules=ext_modules,
    license="Apache 2",
    keywords="mass spectrometry compression",
    description=("A more pythonic wrapper around the MSNumpress library "
                 "for mass spectrometry numerical data compression"),
    author='Joshua Klein, Manuel Koester, Christian Fuefzan',
    author_email='jaklein@bu.edu',
    classifiers=[
        "Development Status :: 4 - Beta",
        "Topic :: Utilities",
        "License :: OSI Approved :: Apache Software License",
        "Topic :: Scientific/Engineering :: Bio-Informatics",
        "Topic :: Scientific/Engineering :: Chemistry",
        "Intended Audience :: Science/Research",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Cython",
        "Programming Language :: C++",
        "Operating System :: OS Independent"
    ])
