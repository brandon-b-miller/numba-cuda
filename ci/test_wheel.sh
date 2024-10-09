#!/bin/bash
# Copyright (c) 2023-2024, NVIDIA CORPORATION

set -euo pipefail

if [ "$1" == "true" ]; then
    USE_PYNVJITLINK=true
else
    USE_PYNVJITLINK=false
fi

rapids-logger "Install testing dependencies"
# TODO: Replace with rapids-dependency-file-generator
python -m pip install \
    psutil \
    cuda-python \
    pytest

if [ "$USE_PYNVJITLINK" == true ]; then
    rapids-logger "Install pynvjitlink"
    python -m pip install pynvjitlink-cu12
    sh build_tests.sh
fi

rapids-logger "Install wheel"
package=$(realpath wheel/numba_cuda*.whl)
echo "Package path: $package"
python -m pip install $package

rapids-logger "Check GPU usage"
nvidia-smi

RAPIDS_TESTS_DIR=${RAPIDS_TESTS_DIR:-"${PWD}/test-results"}/
mkdir -p "${RAPIDS_TESTS_DIR}"
pushd "${RAPIDS_TESTS_DIR}"

rapids-logger "Show Numba system info"
python -m numba --sysinfo

rapids-logger "Run Tests"
ENABLE_PYNVJITLINK=1 python -m numba.runtests numba.cuda.tests -v

popd
