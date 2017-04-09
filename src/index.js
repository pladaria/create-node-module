import path from "path";
import gitignore from "./gitignore.js";
import babelrc from "./babelrc.js";

const plugins = [gitignore, babelrc];

export default {
    async run(options) {
        for (let p of plugins) {
            await p();
        }
    }
};
