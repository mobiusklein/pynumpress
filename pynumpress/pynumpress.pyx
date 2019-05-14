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


np.import_array()

ctypedef cython.floating floating_t


ctypedef fused numeric_collection:
    np.ndarray
    list
    tuple
    object


ctypedef fused byte_array:
    np.ndarray
    bytes
    bytearray
    object


cdef object double_dtype = np.float64
cdef object uint8_dtype = np.uint8


IF int == long:
    DEF PY_VERSION = 3
ELSE:
    DEF PY_VERSION = 2
IF UNAME_SYSNAME != "Windows" and PY_VERSION == 2:
    DEF NEEDS_RUNTIME_PATCH = 1
ELSE:
    DEF NEEDS_RUNTIME_PATCH = 0


cdef np.ndarray[double] coerce_data(numeric_collection data):
    cdef np.ndarray npdata
    if numeric_collection is object:
        IF PY_VERSION == 2 and UNAME_SYSNAME != "Windows":
            if isinstance(data, np.ndarray):
                npdata = data
                if npdata.dtype != double_dtype:
                    return npdata.astype(double_dtype)
                else:
                    return npdata
            else:
                return np.array(list(data), dtype=np.float64)
        ELSE:
            return np.array(list(data), dtype=np.float64)
    elif numeric_collection is list or numeric_collection is tuple:
        return np.array(data, dtype=np.float64)
    elif numeric_collection is np.ndarray:
        npdata = data
        if npdata.dtype != double_dtype:
            return npdata.astype(double_dtype)
        else:
            return npdata


cdef np.ndarray[unsigned char] coerce_data_bytes(byte_array data):
    cdef np.ndarray npdata
    if byte_array is object:
        return np.array(bytearray(data), dtype=uint8_dtype)
    elif byte_array is bytes or byte_array is bytearray:
        return np.frombuffer(data, dtype=uint8_dtype)
    else:
        npdata = data
        if npdata.dtype != uint8_dtype:
            return npdata.astype(uint8_dtype)
        else:
            return npdata

cpdef double optimal_linear_fixed_point(numeric_collection pdata):
    """
    """
    cdef np.ndarray[double] data = coerce_data(pdata)
    dataSize = data.size
    cdef libcpp_vector[double] c_data = data

    cdef double result = _optimalLinearFixedPoint( &c_data[0], dataSize)

    return result

cpdef double optimal_slof_fixed_point(numeric_collection pdata):
    cdef np.ndarray[double] data = coerce_data(pdata)
    dataSize = data.size
    cdef libcpp_vector[double] c_data = data
    cdef double result = _optimalSlofFixedPoint( &c_data[0], dataSize)
    return result

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def encode_linear(numeric_collection _data, double fp):
    '''
    Encodes the doubles in data by first using a
      - lossy conversion to a 4 byte 5 decimal fixed point representation
      - storing the residuals from a linear prediction after first two values
      - encoding by encodeInt (see above)

    The resulting binary is maximally 8 + dataSize * 5 bytes, but much less if the
    data is reasonably smooth on the first order.

    This encoding is suitable for typical m/z or retention time binary arrays.

    On a test set, the encoding was empirically show to be accurate to at least 0.002 ppm.
    '''
    cdef np.ndarray[double] data = coerce_data(_data)
    cdef size_t dataSize = data.size
    cdef unsigned char * res_view = <unsigned char *>malloc(data.size * 5 + 8)
    cdef size_t res_len

    res_len = _encodeLinear(&data[0], dataSize, &res_view[0], fp)
    return np.frombuffer(res_view[:res_len], dtype=np.uint8) # 3.20

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def decode_linear(byte_array data):
    '''
    Decodes data encoded by encode_linear.

    Result array guaranteed to be shorter or equal to (|data| - 8) * 2
    '''
    cdef libcpp_vector[unsigned char] c_data = coerce_data_bytes(data)
    cdef libcpp_vector[double] c_result
    cdef np.ndarray[double, ndim=1] result
    cdef size_t i

    i = c_data.size()
    if i == 8:
        return np.array([], dtype=float)
    elif i < 12:
        raise ValueError("Corrupt input data: not enough bytes to read fixed point!")
    elif i < 16:
        raise ValueError("Corrupt input data: not enough bytes to read second value!")

    _decodeLinear(c_data, c_result)

    result = np.empty(c_result.size(), dtype=float)
    for i in range(c_result.size()):
        result[i] = c_result[i]
    return result

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def encode_slof(numeric_collection _data, double fp):
    """
    Encodes ion counts by taking the natural logarithm, and storing a
    fixed point representation of this. This is calculated as

    unsigned short fp = log(d + 1) * fixedPoint + 0.5

    The result array is exactly |data| * 2 + 8 bytes long
    """
    cdef np.ndarray[double] data = coerce_data(_data)
    cdef unsigned char * res_view = <unsigned char *>malloc(data.size * 2 + 8)
    cdef size_t res_len
    cdef size_t dataSize = data.size
    res_len = _encodeSlof(&data[0], dataSize, &res_view[0], fp)
    return np.frombuffer(res_view[:res_len], dtype=np.uint8) # 3.20

def decode_slof(byte_array data):
    '''
    Decodes data encoded by encode_slof

    The return will include exactly (|data| - 8) / 2 doubles.
    '''
    cdef libcpp_vector[unsigned char] c_data = coerce_data_bytes(data)
    cdef libcpp_vector[double] c_result
    cdef np.ndarray[double, ndim=1] result
    cdef size_t i

    i = c_data.size()
    if i == 8:
        return np.array([], dtype=float)
    elif i < 8:
        raise ValueError("Corrupt input data: not enough bytes to read fixed point!")

    _decodeSlof(c_data, c_result)

    result = np.empty(c_result.size(), dtype=float)
    for i in range(c_result.size()):
        result[i] = c_result[i]
    return result

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def encode_pic(numeric_collection _data):
    '''
    Encodes ion counts by simply rounding to the nearest 4 byte integer,
    and compressing each integer with encodeInt.

    The handleable range is therefore 0 -> 4294967294.

    The resulting binary is maximally dataSize * 5 bytes, but much less if the
    data is close to 0 on average.
    '''
    cdef np.ndarray[double] data = coerce_data(_data)
    cdef unsigned char * res_view = <unsigned char *>malloc(data.size * 5)
    cdef size_t res_len
    cdef size_t dataSize = data.size
    res_len = _encodePic(&data[0], dataSize, &res_view[0])
    return np.frombuffer(res_view[:res_len], dtype=np.uint8) # 3.20

def decode_pic(byte_array data):
    '''
    Decodes data encoded by encode_pic

    Result array guaranteed to be shorter of equal to |data| * 2
    '''
    cdef libcpp_vector[unsigned char] c_data = coerce_data_bytes(data)
    cdef libcpp_vector[double] c_result
    cdef np.ndarray[double, ndim=1] result
    cdef size_t i

    i = c_data.size()
    if i == 0:
        return np.array([], dtype=float)
    _decodePic(c_data, c_result)

    result = np.empty(c_result.size(), dtype=float)
    for i in range(c_result.size()):
        result[i] = c_result[i]
    return result
