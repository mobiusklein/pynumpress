import os

from pynumpress import pynumpress
import numpy as np


data_file = os.path.join(os.path.dirname(__file__), "data", "data.npz")

data_array = np.fromfile(data_file)


def test_slof():
    fixed_point = pynumpress.optimal_slof_fixed_point(data_array)
    encoded = pynumpress.encode_slof(data_array, fixed_point)
    decoded = pynumpress.decode_slof(encoded)
    mask = data_array != 0
    assert data_array.size == decoded.size
    assert np.all(np.abs((data_array[mask] - decoded[mask])) / decoded[mask] < 5e-4)


def test_pic():
    encoded = pynumpress.encode_pic(data_array)
    decoded = pynumpress.decode_pic(encoded)
    mask = data_array != 0
    assert data_array.size == decoded.size
    assert np.all(np.abs((data_array[mask] - decoded[mask])) / decoded[mask] < 1.0)


def test_linear():
    # derived from Java Unit Tests at
    # https://github.com/ms-numpress/ms-numpress/blob/master/src/test/java/ms/numpress/MSNumpressTest.java#L114
    data_array = np.array([100.0, 200.0, 300.00005, 400.00010, 450.00010, 455.00010, 700.00010])
    fixed_point = pynumpress.optimal_linear_fixed_point(data_array)
    encoded = pynumpress.encode_linear(data_array, fixed_point)
    decoded = pynumpress.decode_linear(encoded)
    mask = data_array != 0
    assert data_array.size == decoded.size
    assert np.all(np.abs((data_array[mask] - decoded[mask])) / decoded[mask] < 1e-5)
