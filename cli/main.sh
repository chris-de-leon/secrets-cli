#!/usr/bin/env bash

set -eo pipefail

# NOTE: if you modify a secret on the lastpass website, then make sure
# that you refresh the web page after saving your changes! If you don't
# do this, then this will cause "Error: HTTP response code said error".
# To fix this, you'll need to refresh the page and wait several seconds
# before re-running this script

# NOTE: if you get "Error: Could not find specified account '0'." or get
# "Error: HTTP response code said error", then you can sometimes resolve
# this by (1) creating a dummy secret in the lastpass UI (2) refreshing
# the page (3) deleting the dummy secret (4) re-running this script. It
# can also help to wait a few seconds for the LastPass agent to catch up
# with everything

export FLDR="Dev"

util_get_repo() {
  git rev-parse --show-toplevel
}

util_get_name() {
  local repo="${1:-}"
  local sufx="${2:-}"
  if [[ -z "${sufx}" ]]; then
    basename "${repo}"
  else
    echo "$(basename "${repo}")-${sufx}"
  fi
}

util_get_scrt() {
  echo "${FLDR}/${1:-}"
}

cmd_show() {
  local repo=""
  local sufx=""
  local name=""
  local scrt=""

  while getopts ":s:" opt; do
    case ${opt} in
    s) sufx="${OPTARG}" ;;
    \?)
      echo "error: invalid option -${OPTARG}" >&2
      exit 1
      ;;
    :)
      echo "error: option -${OPTARG} requires an argument" >&2
      exit 1
      ;;
    *)
      echo "Usage: $0 show [-s <suffix>]"
      exit 1
      ;;
    esac
  done

  repo="$(util_get_repo)"
  name="$(util_get_name "${repo}" "${sufx}")"
  scrt="$(util_get_scrt "${name}")"

  lpass sync && lpass show --notes "${scrt}"
}

cmd_push() {
  # Define helper vars
  local ls_output=""
  local matches=""
  local m_count=""
  local fpath=""
  local repo=""
  local sufx=""
  local name=""
  local scrt=""

  # Parse arguments
  while getopts ":f:s:" opt; do
    case ${opt} in
    f) fpath="${OPTARG}" ;;
    s) sufx="${OPTARG}" ;;
    \?)
      echo "error: invalid option -${OPTARG}" >&2
      exit 1
      ;;
    :)
      echo "error: option -${OPTARG} requires an argument" >&2
      exit 1
      ;;
    *)
      echo "Usage: $0 -f <file_path> [-s <suffix>]"
      exit 1
      ;;
    esac
  done

  # Validate file path to secret
  if [[ -z "${fpath}" ]]; then
    echo "error: missing required option -f <file_path>"
    exit 1
  fi
  if [[ ! -f "${fpath}" ]]; then
    echo "error: no file exists at \"${fpath}\""
    exit 1
  fi

  # Build secret name
  repo="$(util_get_repo)"
  name="$(util_get_name "${repo}" "${sufx}")"
  scrt="$(util_get_scrt "${name}")"

  # Make sure our local state is consistent with LastPass servers
  echo "info: syncing local cache with LastPass servers"
  lpass sync

  # Remove all secrets that have a name which conflicts with the input
  ls_output="$(lpass ls --sync=now "${FLDR}")"
  if echo "${ls_output}" | grep -qF "${name}"; then
    matches="$(echo "${ls_output}" | grep -F "${name}")"
    m_count=$(wc -l <<<"${matches}")
    echo "info: removing all secrets with name \"${scrt}\""
    echo "${matches}" | sed -E 's/.*\[id: ([0-9]+)\]/\1/' | xargs -I {} lpass rm --sync=now {}
    echo "info: ${m_count} secret(s) removed"
  else
    echo "info: no conflicting secrets were detected for \"${scrt}\""
  fi

  # Make sure that all deletions have been processed by the LastPass servers
  echo "info: waiting for deletion(s) to be processed by LastPass servers"
  lpass sync

  # Create the secret
  echo "info: saving secret \"${scrt}\""
  lpass add --sync=now --notes "${scrt}" --non-interactive <"${fpath}"

  # Make sure that the new secret has been synced with the LastPass servers
  echo "info: waiting for secret to be added to LastPass servers"
  lpass sync

  # Print results
  echo ""
  lpass show --sync=now --json "${scrt}"
}

cmd_version() {
  echo "v1.1.3"
}

op="${1:-}"
case "${op}" in
version)
  cmd_version "${@:2}"
  ;;
push)
  cmd_push "${@:2}"
  ;;
show)
  cmd_show "${@:2}"
  ;;
*)
  echo "Invalid option: ${op}"
  echo "Usage: $0 {push|show}"
  exit 1
  ;;
esac
