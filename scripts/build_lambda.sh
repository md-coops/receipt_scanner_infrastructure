#!/usr/bin/env bash
set -euo pipefail

# Builds a Lambda deployment directory for a function with third-party
# dependencies. Once run, point that function's `source_dir` in Terraform
# at build/<function_name> instead of functions/<function_name>.
#
# Usage: scripts/build_lambda.sh <function_name>

FUNCTION_NAME="${1:?Usage: build_lambda.sh <function_name>}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/functions/${FUNCTION_NAME}"
BUILD_DIR="${ROOT_DIR}/build/${FUNCTION_NAME}"

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

cp "${SRC_DIR}"/*.py "${BUILD_DIR}/"

if [ -s "${SRC_DIR}/requirements.txt" ] && grep -qv '^\s*#' "${SRC_DIR}/requirements.txt"; then
  pip install -r "${SRC_DIR}/requirements.txt" -t "${BUILD_DIR}" --upgrade
fi

echo "Built ${FUNCTION_NAME} -> ${BUILD_DIR}"
