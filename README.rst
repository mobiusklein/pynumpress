 "A thin, more convenient wrapper around MSNumpress" 

Description
-----------

The original MSNumpress bindings were written to emulate the C++ calling convention, requiring the user to pass a list to the decoding functions which would be filled, one-by-one with floating point numbers from C. This calling convention makes sense when returning the container (in this case, a C++ std:vector<double>) would require copying the entire numerical buffer a second time. It also required you store the data in a `list`, which you would then need to convert into whatever structure you wish to use.

`pynumpress` wraps the API differently, and uses NumPy arrays internally to collect output and return it instead of returning by reference. This also means that the data are only boxed as Python floats if needed.

Installing
----------

To install the latest release, use `pip install pynumpress`. If you wish to build from source, in addition to NumPy, you'll need to install a recent version of `Cython <https://github.com/cython/cython>`_ and a C++ compiler.
