#!/usr/bin/env node
import { echo, mkdir } from "shelljs";
import cnm from "..";
import commandLineArgs from "command-line-args";
import getUsage from "command-line-usage";
import configPath from "application-config-path";
import path from "path";

var pkg = require("../../package.json");
var configfile = path.join(configPath(pkg.name), "settings.json");

try {
    var config = require(configfile);
} catch (e) {
    var config = {
        github: false,
        travis: false,
        ava: false,
        coveralls: false
    };
}

const optionDefinitions = [
    {
        name: "help",
        type: Boolean,
        description: "Display this help message",
        alias: "h"
    },
    {
        name: "update",
        type: Boolean,
        description: "Update the module in the working dir",
        alias: "u"
    },
    {
        name: "name",
        type: String,
        description: "The name of your module",
        alias: "n",
        defaultOption: true
    },
    {
        name: "description",
        type: String,
        description: "A one-line project description",
        alias: "d"
    },
    { name: "dryrun", type: Boolean, description: "Do a dry run" },
    {
        name: "github",
        type: Boolean,
        description: "Create this repo on Github",
        alias: "g"
    },
    {
        name: "travis",
        type: Boolean,
        description: "Setup Travis CI for this module",
        alias: "t"
    },
    {
        name: "ava",
        type: Boolean,
        description: "Setup Ava for tests",
        alias: "a"
    },
    {
        name: "coveralls",
        type: Boolean,
        description: "Setup Coveralls for test coverage",
        alias: "c"
    },
    {
        name: "save-default",
        type: Boolean,
        description: "Modify the default values for -g -t -a -c"
    }
];
const usageDefinitions = [
    {
        header: "Usage:",
        content: [
            {
                cmd: "cnm [-gcat] -n <name> -d <description>",
                help: "Create a new module"
            },
            {
                cmd: "cnm -u [-gcat] -n <name> -d <description>",
                help: "Update the current module."
            },
            {
                cmd: "cnm --save-default -gt",
                help: "Enable Github and Travis by default"
            },
            {
                cmd: "cnm --save-default -gcat",
                help: "Enable everything by default"
            },
            { cmd: "cnm --save-default", help: "Disable everything by default" }
        ]
    },
    {
        header: "Options:",
        optionList: optionDefinitions
    }
];

let options = commandLineArgs(optionDefinitions);

if (Object.keys(options).length === 0 || options.help) {
    console.log(getUsage(usageDefinitions));
    process.exit();
}

if (options["save-default"]) {
    let settings = {
        github: options.github,
        travis: options.travis,
        ava: options.ava,
        coveralls: options.coveralls
    };
    mkdir("-p", path.dirname(configfile));
    echo(JSON.stringify(settings, null, 2)).to(configfile);
} else {
    options.github = !!options.github || !!config.github;
    options.travis = !!options.travis || !!config.travis;
    options.ava = !!options.ava || !!config.ava;
    options.coveralls = !!options.coveralls || !!config.coveralls;
}

cnm.run(options);
