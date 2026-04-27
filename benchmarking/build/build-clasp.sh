#!/bin/bash
set -euo pipefail

# Configuration
CLASP_VERSION="3.4.0"
CLASP_DIR="clasp-${CLASP_VERSION}"
PROGRAMS_DIR="./programs"

# Clone clasp at the specified version (with submodules for libpotassco)
if [ ! -d "${CLASP_DIR}" ]; then
    git clone --recurse-submodules --branch "v${CLASP_VERSION}" \
        https://github.com/potassco/clasp.git "${CLASP_DIR}"
fi

# Build clasp
if [ ! -f "${CLASP_DIR}/build/bin/clasp" ]; then
    cd "${CLASP_DIR}"
    cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Release
    cmake --build build --parallel
    cd ..
fi

# Create the symlink (using absolute path for safety)
CLASP_PATH="$(pwd)/${CLASP_DIR}/build/bin/clasp"
ln -sf "${CLASP_PATH}" "${PROGRAMS_DIR}/clasp-3.4.0"

# Verify it works
"${PROGRAMS_DIR}/clasp-3.4.0" --version
