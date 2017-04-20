#!/usr/bin/env node
import cnm from "..";
import rc from "rc";
import pkg from "../../package.json";

const defaultOptions = {
    disabled: []
};
const conf = rc(pkg.name, defaultOptions);
console.log("conf =", conf);
cnm.run(conf);
