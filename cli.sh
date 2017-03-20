#!/usr/bin/env bash
set -eu
DRYRUN='false'
function dryrun () {
  # Yeah I don't really know bash
  if [[ "$DRYRUN" == 'true' ]]; then
    return 0
  fi
  return 1
}

GITHUB_REPO="$1"
FLAG="$2"
DESCRIPTION="$3"
if [ -z "$GITHUB_REPO" ]; then
  echo 'Usage: newnpm <project-name> [--description \"<description>\"]'
  echo "depends on git, gh, npm, ava, readme, projectz"
  exit 0
fi

echo "Gathering requirements..."
GITHUB_USER="$(gh me | head -n 2 | tail -n 1)"
# normalize repository name
if [[ "$GITHUB_REPO" != */* ]] ; then
  GITHUB_REPO="$GITHUB_USER/$GITHUB_REPO"
fi
# remove repository user to isolate project name
PROJECT=${GITHUB_REPO#*/}
AUTHOR_NAME=${AUTHOR_NAME:-"$(npm config get init-author-name)"}
AUTHOR_NAME=${AUTHOR_NAME:-"$(git config user.name)"}
AUTHOR_EMAIL=${AUTHOR_EMAIL:-"$(npm config get init-author-email)"}
AUTHOR_EMAIL=${AUTHOR_EMAIL:-"$(git config user.email)"}
LICENSE="$(npm config get init-license)"
if [ -f ~/.npmrc ] && grep -o '//registry.npmjs.org/:_authToken' ~/.npmrc &>/dev/null; then
  NPM_PUBLISH_API_KEY="$(sed -e '/^\/\/registry.npmjs.org\/:_authToken=\(.*\)/! d' -e 's/^\/\/registry.npmjs.org\/:_authToken=\(.*\)/\1/' ~/.npmrc)"
fi

echo "Creating $PROJECT directory..."
mkdir "$PROJECT"
cd "$PROJECT"

echo "Generating git repo..."
dryrun || gh create-repo "$GITHUB_REPO" -d "$DESCRIPTION"
git init
git remote add origin "https://github.com/$GITHUB_REPO"
echo "node_modules" > .gitignore

echo "Generating package.json..."
echo '{
  "name": "'"$PROJECT"'",
  "version": "0.0.0",
  "description": "'"$DESCRIPTION"'",
  "main": "'"$PROJECT"'.js",
  "scripts": {
    "docs": "projectz && mos"
  },
  "keywords": [],
  "author": "'"$AUTHOR_NAME <$AUTHOR_EMAIL>"'",
  "license": "'"$LICENSE"'"
}' > package.json
# populate the readme, repository, etc fields.
npm init -y

echo 'Generating test directory...'
#ava --init # Takes too long
mkdir test
echo "import test from 'ava'

test('foo', t => {
    t.is(2+2, 5)
})" > "test/$PROJECT.test.js"
echo "'use strict'
" > "$PROJECT.js"

echo 'Generating README.md and LICENSE.md...'
echo '
<!-- TITLE -->
<!-- BADGES -->
<!-- DESCRIPTION -->

## Installation

Download node at [nodejs.org](http://nodejs.org) and install it, if you haven'"'"'t already.

Then in the terminal, run:

```sh
npm install '"$PROJECT"' --save
```

## Tests

First clone this repository to get the source code. Then in the topmost repo
directory run:

```sh
npm install
npm test
```

<!-- LICENSE -->

_Parts of this file are based on [package-json-to-readme](https://github.com/zeke/package-json-to-readme)_

_README.md (and other files) are maintained using [mos](https://github.com/mosjs/mos) and [projectz](https://github.com/bevry/projectz)_

' > README.md
echo '<!-- LICENSEFILE/ -->
<!-- /LICENSEFILE -->' > LICENSE.md
projectz compile

if which travis &>/dev/null && [ ! -z "$NPM_PUBLISH_API_KEY" ]; then
  echo 'Generating .travis.yml...'
  echo "language: node_js
node_js: 6
deploy:
  provider: npm
  email: $AUTHOR_EMAIL
  on:
    node: node
    tags: true
    branch: master
    repo: $GITHUB_REPO" > .travis.yml
  dryrun || travis sync
  dryrun || travis enable
  dryrun || travis encrypt "$NPM_PUBLISH_API_KEY" --add deploy.api_key
fi

git add -A

