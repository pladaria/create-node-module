# create-node-module
Creates a new npm module with all the boilerplate for transpiling, linting, publishing, testing, coverage, readme badges, etc.

## Install

    npm install -g create-node-module

## Automatically configures

- GitHub repo
- AVA
- ESLint
- Babel
- Coverage with nyc
- Coverage reports with coveralls
- CI with travis
- npm targets for building, publishing, linting, testing...

## Configuration

This module uses [`rc`](https://www.npmjs.com/package/rc) for loading default values. It supports many ways, including command line arguments, environment variables, and config files in INI or JSON. Read the `rc` page on npm for details.

Here's an example config file you might use:

```ini
; $HOME/.create-node-modulerc
license = MIT
copyrightHolder = Your Name
babelPresets[] = env
babelPlugins[] = transform-es2015-modules-commonjs
babelPlugins[] = transform-async-to-generator
babelPlugins[] = transform-object-rest-spread
```

## Usage


## Contributing

All feedback is welcome!

## LICENSE

MIT
