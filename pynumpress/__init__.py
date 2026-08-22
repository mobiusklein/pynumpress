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


from .pynumpress import (
    decode_linear,
    decode_pic,
    decode_slof,
    encode_linear,
    encode_pic,
    encode_slof,
    optimal_linear_fixed_point,
    optimal_slof_fixed_point,
)
from .version import version as __version__

__all__ = [
    "__version__",
    "decode_linear",
    "decode_pic",
    "decode_slof",
    "encode_linear",
    "encode_pic",
    "encode_slof",
    "optimal_linear_fixed_point",
    "optimal_slof_fixed_point",
]
