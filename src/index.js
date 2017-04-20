import path from "path";
import github from "./github.js";
import gitignore from "./gitignore.js";
import babelrc from "./babelrc.js";
import license from "./license.js";

const plugins = [github, gitignore, babelrc, license];

export default {
    async run(options) {
        for (let plugin of plugins) {
            options = await plugin(options);
        }
    }
};
