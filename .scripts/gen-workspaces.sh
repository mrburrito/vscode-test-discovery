#!/usr/bin/env bash

set -e -u -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSCODE_DIR="${ROOT_DIR}/.vscode"
WORKSPACE_BASE_SETTINGS="${VSCODE_DIR}/.workspace-base-settings.json"

function list_projects() {
    local root="$1"
    find "${ROOT_DIR}/${root}" -maxdepth 1 -type d -name "[a-z]*" | grep -v -E "${ROOT_DIR}/${root}$" | sort
}

echo >&2 "Building base configuration..."

function folder_def() {
    local folder_path="$1"
    local venv="${folder_path//${ROOT_DIR}/..}/.venv/bin/python"
    local group project folder_name

    if [[ -n "${2:-}" ]]; then
        folder_name="${2}"
    else
        project="$(basename "${folder_path}")"
        group="$(basename "$(dirname "${folder_path}")")"
        folder_name="${group} :: ${project}"
    fi

    jq -n --arg path "${folder_path//${ROOT_DIR}/..}/" \
        --arg name "${folder_name}" \
        --arg venv "${venv}" \
        '
            {
                name: $name,
                path: $path,
            }
        '
}

workspace_base="$(jq --sort-keys \
    --argjson root "$(folder_def "${ROOT_DIR}" root_project)" \
    '
        {
            folders: [$root],
            settings: .
        }
    ' "${WORKSPACE_BASE_SETTINGS}")"

function gen_workspace() {
    local ws_name="$1"
    shift
    local source_roots=($@)

    local workspace_file="${VSCODE_DIR}/${ws_name}.code-workspace"
    local folders=()
    local workspace="${workspace_base}"

    for root in ${source_roots[@]}; do
        folders+=($(list_projects ${root}))
    done
    for folder in ${folders[@]}; do
        workspace="$(echo "${workspace}" | jq --argjson folder "$(folder_def "${folder}")" '.folders += [$folder]')"
    done

    echo >&2 "Generating Workspace ${ws_name} [${workspace_file}]"
    echo "${workspace}" >"${workspace_file}"
}

mkdir -p "${VSCODE_DIR}"

gen_workspace root group1 group2 group3 group4
gen_workspace group1 group1
gen_workspace group2 group2
gen_workspace group3 group3
gen_workspace group4 group4
