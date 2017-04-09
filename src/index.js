import path from "path";
import gitignore from "./gitignore.js";

const plugins = [gitignore];

export default {
    async run(options) {
        for (let p of plugins) {
            await p();
        }
    }
};
