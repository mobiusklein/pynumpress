import os
import platform
from setuptools import setup, Extension, find_packages
import pip

try:
    import numpy as np
except ImportError:
    pip.main(['install', 'numpy'])
    import numpy as np

extra_compile_args = []
if platform.system().lower() == 'windows':
    # This may fail if compiled on Windows with a compiler
    # that doesn't provide a cl.exe compatability frontend
    # like mingw
    extra_compile_args = ['/EHsc']

try:
    from Cython.Build import cythonize
except:
    pip.main(['install', 'cython'])

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


setup(
    name="pynumpress",
    packages=find_packages(),
    version='0.0.2',
    install_requires=['numpy'],
    include_dirs=[np.get_include()],
    ext_modules=ext_modules)
