#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${ENV_NAME:-gr00t}"
PYTHON_VERSION="${PYTHON_VERSION:-3.10}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${PROJECT_DIR}/environment.conda.yml"

if ! command -v conda >/dev/null 2>&1; then
  echo "conda was not found. Install Miniforge/Miniconda first, then rerun this script." >&2
  exit 1
fi

cat >"${ENV_FILE}" <<YAML
name: ${ENV_NAME}
channels:
  - conda-forge
dependencies:
  - python=${PYTHON_VERSION}
  - pip
  - git
  - git-lfs
  - ffmpeg
  - cmake
  - ninja
  - packaging
  - setuptools
  - wheel
  - pip:
      - uv
YAML

echo "Using project directory: ${PROJECT_DIR}"
echo "Writing conda environment file: ${ENV_FILE}"

if conda env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  echo "Conda environment '${ENV_NAME}' already exists; updating it."
  conda env update -n "${ENV_NAME}" -f "${ENV_FILE}" --prune
else
  echo "Creating conda environment '${ENV_NAME}'."
  conda env create -f "${ENV_FILE}"
fi

CONDA_BASE="$(conda info --base)"
# shellcheck disable=SC1091
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate "${ENV_NAME}"

cd "${PROJECT_DIR}"

git lfs install
git submodule update --init --recursive

uv sync --active --python "${PYTHON_VERSION}"

python -c "import gr00t; print('GR00T installed successfully')"

cat <<EOF

Done.

Activate the environment with:
  conda activate ${ENV_NAME}

For multiple datasets on Linux, join paths with ':' in --dataset-path, for example:
  --dataset-path "/path/to/dataset_a:/path/to/dataset_b"
EOF
