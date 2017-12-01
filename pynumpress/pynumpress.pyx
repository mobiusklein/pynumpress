# distutils: language = c++
# cython: embedsignature=True
'''
Copyright 2013 Hannes Roest
Copyright 2017 <insert-name-here>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
'''


from libc.stdlib cimport malloc, free
from libcpp.vector cimport vector as libcpp_vector
from cython.operator cimport dereference as deref, preincrement as inc, address as address
from MSNumpress cimport encodeLinear as _encodeLinear
from MSNumpress cimport decodeLinear as _decodeLinear
from MSNumpress cimport optimalLinearFixedPoint as _optimalLinearFixedPoint
from MSNumpress cimport encodeSlof as _encodeSlof
from MSNumpress cimport decodeSlof as _decodeSlof
from MSNumpress cimport optimalSlofFixedPoint as _optimalSlofFixedPoint
from MSNumpress cimport encodePic as _encodePic
from MSNumpress cimport decodePic as _decodePic

import cython

import numpy as np
cimport numpy as np


ctypedef cython.floating floating_t


cpdef double optimal_linear_fixed_point(np.ndarray[floating_t] data):
    """
    """
    dataSize = data.size
    cdef libcpp_vector[double] c_data = data

    cdef double result = _optimalLinearFixedPoint( &c_data[0], dataSize)

    return result

cpdef double optimal_slof_fixed_point(np.ndarray[floating_t] data):
    """
    """
    dataSize = data.size
    cdef libcpp_vector[double] c_data = data
    cdef double result = _optimalSlofFixedPoint( &c_data[0], dataSize)
    return result

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def encode_linear(np.ndarray[floating_t] _data, double fp):
    cdef np.ndarray[double] data
    if floating_t is not double:
        data = _data.astype('double')
    else:
        data = _data
    cdef size_t dataSize = data.size
    cdef unsigned char * res_view = <unsigned char *>malloc(data.size * 5 + 8)
    cdef size_t res_len

    res_len = _encodeLinear(&data[0], dataSize, &res_view[0], fp)
    return np.frombuffer(res_view[:res_len], dtype=np.uint8) # 3.20

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def decode_linear(np.ndarray[unsigned char] data):
    cdef libcpp_vector[unsigned char] c_data = data
    cdef libcpp_vector[double] c_result
    cdef np.ndarray[double, ndim=1] result
    cdef size_t i

    _decodeLinear(c_data, c_result)

    result = np.empty(c_result.size(), dtype=float)
    for i in range(c_result.size()):
        result[i] = c_result[i]
    return result

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def encode_slof(np.ndarray[floating_t] _data, double fp):
    cdef np.ndarray[double] data
    if floating_t is not double:
        data = _data.astype('double')
    else:
        data = _data
    cdef unsigned char * res_view = <unsigned char *>malloc(data.size * 2 + 8)
    cdef size_t res_len
    cdef size_t dataSize = data.size
    res_len = _encodeSlof(&data[0], dataSize, &res_view[0], fp)
    return np.frombuffer(res_view[:res_len], dtype=np.uint8) # 3.20

def decode_slof(data):
    cdef libcpp_vector[unsigned char] c_data = data
    cdef libcpp_vector[double] c_result
    cdef np.ndarray[double, ndim=1] result
    cdef size_t i

    _decodeSlof(c_data, c_result)

    result = np.empty(c_result.size(), dtype=float)
    for i in range(c_result.size()):
        result[i] = c_result[i]
    return result

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def encode_pic(np.ndarray[floating_t] _data):
    cdef np.ndarray[double] data
    if floating_t is not double:
        data = _data.astype('double')
    else:
        data = _data
    cdef unsigned char * res_view = <unsigned char *>malloc(data.size * 5)
    cdef size_t res_len
    cdef size_t dataSize = data.size
    res_len = _encodePic(&data[0], dataSize, &res_view[0])
    return np.frombuffer(res_view[:res_len], dtype=np.uint8) # 3.20

def decode_pic(data):
    cdef libcpp_vector[unsigned char] c_data = data
    cdef libcpp_vector[double] c_result
    cdef np.ndarray[double, ndim=1] result
    cdef size_t i

    _decodePic(c_data, c_result)

    result = np.empty(c_result.size(), dtype=float)
    for i in range(c_result.size()):
        result[i] = c_result[i]
    return result
