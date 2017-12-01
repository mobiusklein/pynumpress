import os
import platform
from setuptools import setup, Extension, find_packages
from Cython.Distutils import build_ext

import numpy as np

extra_compile_args = []
pltf = platform.system()
if pltf == 'Windows':
    extra_compile_args = ['/EHsc']


ext_modules = [
    Extension(
        "pynumpress.pynumpress",
        [
            os.path.join('pynumpress/pynumpress.pyx'),
            os.path.join('pynumpress/MSNumpress.cpp'),
        ],
        language='c++',
        extra_compile_args=extra_compile_args,
    )
]


setup(
    name="pynumpress",
    packages=find_packages(),
    version='0.0.1',
    include_dirs=[np.get_include()],
    ext_modules=ext_modules,
    cmdclass={'build_ext': build_ext},)
