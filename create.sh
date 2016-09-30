#!/usr/bin/env bash
TRUE='true'
FALSE='false'
YEAR=$(date +%Y)
CONFIG_FILE=$HOME"/.create-node-module.cfg"

print() {
    echo -ne "$@ "
}

println() {
    echo -ne "$@\n"
}

ok() {
    echo -ne "- $@\n"
}

write_config() {
    ok "Write config: $CONFIG_FILE"
    echo "# create-node-module config
    GITHUB_USER=\"$GITHUB_USER\"
    USER_NAME=\"$USER_NAME\"
    USER_EMAIL=\"$USER_EMAIL\"
    " > $CONFIG_FILE
}

# Read config
GITHUB_USER=$USER
USER_NAME=$USER
USER_EMAIL=""
GITHUB_URL='<url to repo>'
echo $CONFIG_FILE
if [ -f "$CONFIG_FILE" ]; then
    . $CONFIG_FILE
else
    write_config
fi

confirm() {
    read -p "[y/n]: " -n 1 -r REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo $TRUE
    else
        echo $FALSE
    fi
}

println "Press ^C at any time to quit."

print "Module name:"
read MODULE_NAME

if [ "$MODULE_NAME" == "" ]; then
    println "Module name cannot be empty!"
    exit 1
fi

print "Module description [No description]:"
read VALUE
MODULE_DESCRIPTION=${VALUE:-No description}

print "Your name (to display in license and package.json) [$USER_NAME]:"
read VALUE
USER_NAME=${VALUE:-$USER_NAME}

print "Your email (to display in license and package.json) [$USER_EMAIL]:"
read VALUE
USER_EMAIL=${VALUE:-$USER_EMAIL}

println "Creating module folder: $MODULE_NAME"
mkdir $MODULE_NAME
cd $MODULE_NAME

ok "Write .gitignore"
echo "\
logs
*.log
npm-debug.log*
pids
*.pid
*.seed
.coveralls.yml
.grunt
.lock-wscript
.npm
.node_repl_history
.nyc_output
lib-cov
coverage
build/Release
node_modules
jspm_packages
dist\
" > .gitignore

ok "Write .babelrc"
echo "{
  'presets': ['es2015'],
  'plugins': ['transform-object-rest-spread', 'transform-react-jsx']
}" | tr "'" '"' > .babelrc

ok "Write .eslintrc"
echo "\
extends:
  eslint:recommended
parserOptions:
  ecmaVersion: 6
  sourceType: module
env:
  node: true
rules:
  semi: [error, always]
  indent: [error, 4, {SwitchCase: 1}]\
" > .eslintrc

ok "Write .travis.yml"
echo "\
language: node_js
node_js:
  - '6'
  - '5'
after_success: 'npm run coveralls'\
" > .travis.yml

ok "Create ./src"
mkdir src

ok "Write src/index.js"
echo "\
export default sum = (a, b) => a + b;\
" > "src/index.js"

ok "Create ./test"
mkdir "test"

ok "Write test/test.js"
echo "\
import test from 'ava';
import sum from '../src'

test('1 + 1 = 2', t => {
    t.is(sum(1, 1), 2);
});\
" > "test/test.js"

ok "Write LICENSE"
echo "\
MIT License

Copyright (c) $YEAR $USER_NAME <$USER_EMAIL>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.\
" > LICENSE

ok "Write README.md"
echo "\
# $MODULE_NAME

$MODULE_DESCRIPTION

## Install

    npm install --save $MODULE_NAME

## Example

tbd

## License

MIT\
" > README.md

ok "Write initial package.json"
echo "\
{
  'name': '$MODULE_NAME',
  'version': '0.0.0',
  'description': '$MODULE_DESCRIPTION',
  'main': 'dist/index.js',
  'author': '$USER_NAME <$USER_EMAIL>',
  'scripts': {
    'lint': 'eslint ./src',
    'test': 'nyc --reporter=lcov ava --verbose test/test.js',
    'report': 'nyc report --reporter=html && opn coverage/index.html',
    'clean': 'rimraf dist coverage .nyc_output',
    'build': 'babel src --out-dir dist',
    'prepublish': 'npm run lint && npm test && npm run build',
    'coveralls': 'cat ./coverage/lcov.ok | ./node_modules/.bin/coveralls'
  },
  'dependencies': {},
  'devDependencies': {
    'ava': '^`npm info ava version`',
    'babel-cli': '^`npm info babel-cli version`',
    'babel-plugin-transform-object-rest-spread': '^`npm info babel-plugin-transform-object-rest-spread version`',
    'babel-preset-es2015': '^`npm info babel-preset-es2015 version`',
    'coveralls': '^`npm info coveralls version`',
    'eslint': '^`npm info eslint version`',
    'nyc': '^`npm info nyc version`',
    'opn-cli': '^`npm info opn-cli version`',
    'rimraf': '^`npm info rimraf version`'
  },
  'publishConfig': {
    'repository': 'https://registry.npmjs.org'
  },
  'ava': {
    'require': [
      'babel-register'
    ],
    'babel': 'inherit'
  },
  'license': 'MIT',
  'directories': {
    'test': 'test'
  }
}" | tr "'" '"' > package.json

print "Create GitHub repository?"
if [ `confirm` == "$TRUE" ]; then
    println ""

    print "Your GitHub username [$GITHUB_USER]:"
    read VALUE
    GITHUB_USER=${VALUE:-$GITHUB_USER}

    print "Repository name [$MODULE_NAME]:"
    read VALUE
    REPO_NAME=${VALUE:-$MODULE_NAME}
    println "Creating: https://github.com/$GITHUB_USER/$REPO_NAME"

    GITHUB_URL="https://github.com/$GITHUB_USER/$MODULE_NAME"

    ok "Creating repo, enter your GitHub password when requested..."
    curl -u $GITHUB_USER "https://api.github.com/user/repos" -d "{\"name\":\"$REPO_NAME\",\"description\":\"$MODULE_DESCRIPTION\"}" > /dev/null

    git init
    git add -A .
    git commit -m "first commit"
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    git push origin master
    npm init

    git add .
    git commit -m "update package json"
    git push origin master
else
    println ""
fi

write_config

print "Review package.json fields now [ENTER]"
read

