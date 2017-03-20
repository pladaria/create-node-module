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

## Usage

    Usage:

      cnm [-gcat] -n <name> -d <description>      Create a new module
      cnm -u [-gcat] -n <name> -d <description>   Update the current module.
      cnm --save-default -gt                      Enable Github and Travis by default
      cnm --save-default -gcat                    Enable everything by default
      cnm --save-default                          Disable everything by default

    Options:

      -h, --help                 Display this help message
      -u, --update               Update the module in the working dir
      -n, --name string          The name of your module
      -d, --description string   A one-line project description
      --dryrun                   Do a dry run
      -g, --github               Create this repo on Github
      -t, --travis               Setup Travis CI for this module
      -a, --ava                  Setup Ava for tests
      -c, --coveralls            Setup Coveralls for test coverage
      --save-default             Modify the default values for -g -t -a -c

## TODOs

- [x] Initial prototype
- [ ] Port from shell to JavaScript
- [ ] Cache global values (like author name, email) in config file
- [x] Add proper CLI parser
- [ ] Make interactive with inquirer
- [ ] Use [`update-readme`](https://github.com/update-readme/update-readme) to create default README

## Contributing

All feedback is welcome!

## LICENSE

MIT
