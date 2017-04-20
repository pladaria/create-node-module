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
dryrun || gh repo --new "$PROJECT" --description "$DESCRIPTION"
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

## Installation


## Tests

First clone this repository to get the source code. Then in the topmost repo
directory run:

```sh
npm install
npm test
```

## License


' > README.md
update-readme -p name-and-description -p installation -p license

echo 'This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>

' > LICENSE.md

if which travis &>/dev/null && [ ! -z "$NPM_PUBLISH_API_KEY" ]; then
  echo 'Generating .travis.yml...'
  echo "language: node_js
node_js: 6
deploy:
  provider: npm
  email: $AUTHOR_EMAIL
  on:
    skip_cleanup: true
    tags: true
    branch: master
    repo: $GITHUB_REPO" > .travis.yml
  dryrun || travis login --github-token $GH_TOKEN
  dryrun || travis sync
  dryrun || travis enable
  dryrun || travis encrypt "$NPM_PUBLISH_API_KEY" --add deploy.api_key
fi

git add -A

