#!/bin/bash

set -e

cat << EOS | sed -i '1r /dev/stdin' Assets/MadCrew.VR/CHANGELOG.md

## [${INPUT_RELEASE_VERSION##v}] - $(date "+%Y-%m-%d")

${INPUT_RELEASE_SUMMARY}

$(echo "${INPUT_RELEASE_BODY}" | sed 's/^#/\#\#/')
EOS
cat Assets/MadCrew.VR/package.json | jq -Mr '. | .version = "'"${INPUT_RELEASE_VERSION##v}"'"' > /tmp/package.json
mv /tmp/package.json Assets/MadCrew.VR/package.json

#if [ -z "${INPUT_NPM_REGISTRY_URL}" ]; then
#    INPUT_NPM_REGISTRY_URL=$(cat .npmrc | sed 's/^registry=//')
#    echo $(cat .npmrc | grep '^registry=' | sed 's/^registry=https://')'/:_authToken="'${INPUT_NPM_AUTH_TOKEN}'"' >> ~/.npmrc
#else
#    echo $(echo -n "${INPUT_NPM_REGISTRY_URL}" | sed 's/^https://')'/:_authToken="'${INPUT_NPM_AUTH_TOKEN}'"' >> ~/.npmrc
#fi
echo "//npm.pkg.github.com/:_authToken=${INPUT_NPM_AUTH_TOKEN}" > .npmrc
echo "registry=https://npm.pkg.github.com/madcrewteam" >> .npmrc
echo "@madcrewteam:registry=https://npm.pkg.github.com" >> .npmrc
echo "@madcrewteam:registry=https://npm.pkg.github.com" >> .npmrc

npm publish --tag latest --registry ${INPUT_NPM_REGISTRY_URL} ${INPUT_PACKAGE_DIRECTORY_PATH}

git config --global user.email "github-actions@example.com"
git config --global user.name "GitHub Actions"
git config lfs.locksverify false
#git checkout -b "temporary-$(date '+%Y%m%d%H%M%S')"
git add .
git commit -m ":up: Bump up version: ${INPUT_RELEASE_VERSION}" && git push --no-verify "https://${INPUT_GITHUB_ACTOR}}:${INPUT_GITHUB_TOKEN}@github.com/${INPUT_GITHUB_REPOSITORY}.git" HEAD:${INPUT_RELEASE_BRANCH} || true
git tag -d ${INPUT_RELEASE_VERSION}
git tag ${INPUT_RELEASE_VERSION}
git push --tags --force
