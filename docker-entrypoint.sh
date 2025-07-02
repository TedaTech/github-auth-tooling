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
# You can probably adjust this to use `jq` or the latest version of `yq` without too much trouble.

setupGhAppAuth() {
  if [[ "${GITHUB_APP_ID}" != "" ]] && [[ -e "${GITHUB_APP_SECRET_PATH}" ]] ; then
    # Create a temporary JWT for API access
    GITHUB_JWT=$( jwt encode --secret "@${GITHUB_APP_SECRET_PATH}" -i "${GITHUB_APP_ID}" -e "10 minutes" --alg RS256 )

    # TODO: Add picking correct installation based on the organisation
    #  Request installation information; note that this assumes there's just one installation (this is a private GitHub app);
    #  if you have multiple installations you'll have to customize this to pick out the installation you are interested in
    APP_TOKEN_URL=$( curl -s -H "Authorization: Bearer ${GITHUB_JWT}" -H "Accept: application/vnd.github.v3+json" https://api.github.com/app/installations | yq r - '[0].access_tokens_url' )

    # Now POST to the installation token URL to generate a new access token we can use to with with the gh and hub command lines
    export GITHUB_TOKEN=$( curl -s -X POST -H "Authorization: Bearer ${GITHUB_JWT}" -H "Accept: application/vnd.github.v3+json" ${APP_TOKEN_URL} | yq r - token )

    # Configure gh as an auth provider for git so we can use git push / pull / fetch with github.com URLs
    gh auth setup-git
  fi
}

# Create the .gitconfig and .git-credentials files
setupGhAppAuth

# copy the .gitconfig and .git-credentials files to the basic-auth workspace
mkdir -p "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}"
cp -f "${HOME}/.gitconfig" "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.gitconfig"
cp -f "${HOME}/.git-credentials" "${WORKSPACE_BASIC_AUTH_DIRECTORY_PATH}/.git-credentials"