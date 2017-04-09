import fs from 'fs'

import { createPromptModule, Separator } from "inquirer";
import pify from "pify";
const prompt = createPromptModule();

export default BabelRC 

async function BabelRC () {
    
    let presets = [
        { name: 'env (replaces es2015, es2016, es2017, latest)', short: 'env', value: 'env'},
        'es2015',
        'es2016',
        'es2017',
        { name: 'latest (deprecated in favor of env)', short: 'latest', value: 'latest'},
        'react',
        'flow',
    ]
    
    let plugins = [
        "transform-es2015-modules-commonjs",
        "transform-async-to-generator",
        "transform-object-rest-spread",
        'transform-react-jsx'
    ]

    let questions = [
        { message: "Add .babelrc?", type: "confirm", name: "confirm",  default: true },
        {
            when: ans => ans.confirm,
            message: "select presets",
            type: "checkbox",
            name: "presets",
            choices: presets,
            default: ["env"]
        },
        {
            when: ans => ans.confirm,
            message: "select plugins",
            type: "checkbox",
            name: "plugins",
            choices: plugins,
            default: plugins
        },
    ];

    

    let answers = await prompt(questions);
    if (answers.confirm) {
        // let out = fs.createWriteStream(".gitignore");
        // await pify(gitignore.writeFile)({ type: answers.type, writable: out });
        let json = {
            presets: answers.presets,
            plugins: answers.plugins
        }
        fs.writeFileSync('.babelrc', JSON.stringify(json, null, 2))
    }
}

if (!module.parent) {
    BabelRC();
}
