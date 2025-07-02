#!/usr/bin/env sh
set -eu

# Set defaults
PARAM_VERBOSE="${PARAM_VERBOSE:-false}"

if [ "${PARAM_VERBOSE}" = "true" ] ; then
  set -x
fi

# If we have GitHub App credentials, this will set GITHUB_TOKEN and run gh auth setup-git which will make it
# so that git fetch, pull, and push will use it via the gh cli if the remote URL is https://github.com/
# GITHUB_APP_SECRET_PATH must be the path to the github app secret with the .pem file extension
# Dependencies:
#
# - [jwt-cli](https://github.com/mike-engel/jwt-cli)
# - [yq v3](https://github.com/mikefarah/yq/tree/v3.x)
# - curl
# - [gh](https://cli.github.com/)
#

# Read GitHub App credentials from mounted secret files if available
if [ -n "${GITHUB_SECRET_MOUNT_PATH:-}" ] && [ -n "${GITHUB_SECRET_APP_ID_NAME:-}" ] && [ -n "${GITHUB_SECRET_APP_INSTALLATION_ID_NAME:-}" ] && [ -n "${GITHUB_SECRET_APP_PRIVATE_KEY_NAME:-}" ]; then
  GITHUB_APP_ID=""
  GITHUB_APP_INSTALLATION_ID=""
  GITHUB_APP_SECRET_PATH=""
  if [ -f "${GITHUB_SECRET_MOUNT_PATH}/${GITHUB_SECRET_APP_ID_NAME}" ]; then
    GITHUB_APP_ID=$(cat "${GITHUB_SECRET_MOUNT_PATH}/${GITHUB_SECRET_APP_ID_NAME}")
  fi
  if [ -f "${GITHUB_SECRET_MOUNT_PATH}/${GITHUB_SECRET_APP_INSTALLATION_ID_NAME}" ]; then
    GITHUB_APP_INSTALLATION_ID=$(cat "${GITHUB_SECRET_MOUNT_PATH}/${GITHUB_SECRET_APP_INSTALLATION_ID_NAME}")
  fi
  if [ -f "${GITHUB_SECRET_MOUNT_PATH}/${GITHUB_SECRET_APP_PRIVATE_KEY_NAME}" ]; then
    GITHUB_APP_SECRET_PATH="${GITHUB_SECRET_MOUNT_PATH}/${GITHUB_SECRET_APP_PRIVATE_KEY_NAME}"
  fi
  export GITHUB_APP_ID
  export GITHUB_APP_INSTALLATION_ID
  export GITHUB_APP_SECRET_PATH
fi

# Setup GitHub App authentication if credentials are available
gh auth setup-git

# copy the .gitconfig and .git-credentials files to the basic-auth workspace
mkdir -p "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}"
cp -f "${HOME}/.gitconfig" "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.gitconfig"
cp -f "${HOME}/.git-credentials" "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.git-credentials"