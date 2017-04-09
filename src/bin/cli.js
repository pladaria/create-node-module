#!/usr/bin/env node
import cnm from "..";
import rc from "rc";
import pkg from "../../package.json";

const defaultOptions = {};
const conf = rc(pkg.name, defaultOptions);
cnm.run(conf);
