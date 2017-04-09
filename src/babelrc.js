import fs from "fs";

import { createPromptModule, Separator } from "inquirer";
const prompt = createPromptModule();

let presets = [
    {
        name: "env (replaces es2015, es2016, es2017, latest)",
        short: "env",
        value: "env"
    },
    "es2015",
    "es2016",
    "es2017",
    {
        name: "latest (deprecated in favor of env)",
        short: "latest",
        value: "latest"
    },
    "react",
    "flow"
];

let plugins = ["transform-es2015-modules-commonjs", "transform-async-to-generator", "transform-object-rest-spread", "transform-react-jsx"];

export default BabelRC;

async function BabelRC(options) {
    if (options.disabled.includes("babelrc")) return options;

    let questions = [
        {
            message: "Add .babelrc?",
            type: "confirm",
            name: "confirm",
            default: true
        },
        {
            when: ans => ans.confirm,
            message: "select presets",
            type: "checkbox",
            name: "babelPresets",
            choices: presets,
            default: options.babelPresets
        },
        {
            when: ans => ans.confirm,
            message: "select plugins",
            type: "checkbox",
            name: "babelPlugins",
            choices: plugins,
            default: options.babelPlugins
        }
    ];

    let answers = await prompt(questions);
    if (answers.confirm) {
        let json = {
            presets: answers.babelPresets,
            plugins: answers.babelPlugins
        };
        fs.writeFileSync(".babelrc", JSON.stringify(json, null, 2));
    }
    options.babelPresets = answers.babelPresets;
    options.babelPlugins = answers.babelPlugins;
    return options;
}

if (!module.parent) {
    BabelRC();
}
