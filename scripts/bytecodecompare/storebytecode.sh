#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Script used for cross-platform comparison of the bytecode generated by the compiler.
# Splits all test source code into multiple files, generates bytecode and metadata
# for each file and combines it into a single report.txt file.
#
# The script is meant to be executed in CI on all supported platforms. All generated
# reports must be identical for a given compiler version.
#
# ------------------------------------------------------------------------------
# This file is part of solidity.
#
# solidity is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# solidity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with solidity.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2017 solidity contributors.
#------------------------------------------------------------------------------

set -e

REPO_ROOT="$(dirname "$0")"/../..
cd "$REPO_ROOT"
REPO_ROOT=$(pwd) # make it absolute

BUILD_DIR="${1:-${REPO_ROOT}/build}"

echo "Compiling all test contracts into bytecode..."
TMPDIR=$(mktemp -d)
(
    cd "$TMPDIR"

    "$REPO_ROOT"/scripts/isolate_tests.py "$REPO_ROOT"/test/

    if [[ "$SOLC_EMSCRIPTEN" = "On" ]]
    then
        echo "Installing solc-js..."
        # npm install solc
        git clone --depth 1 https://github.com/ethereum/solc-js.git solc-js
        cp "$REPO_ROOT/emscripten_build/libsolc/soljson.js" solc-js/
        pushd solc-js/
        npm install
        npm run build
        popd

        cp "$REPO_ROOT/scripts/bytecodecompare/prepare_report.js" .
        npm install ./solc-js/dist

        echo "Running the compiler..."
        # shellcheck disable=SC2035
        ./prepare_report.js *.sol > report.txt
        echo "Finished running the compiler."
    else
        "$REPO_ROOT/scripts/bytecodecompare/prepare_report.py" "$BUILD_DIR/solc/solc"
    fi

    cp report.txt "$REPO_ROOT"
)
rm -rf "$TMPDIR"
echo "Storebytecode finished."
