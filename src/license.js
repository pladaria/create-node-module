"use strict";
import fs from "fs";
import { createPromptModule, Separator } from "inquirer";
import licenseList from "spdx-license-list/simple";
import licenseFull from "spdx-license-list/full";
const prompt = createPromptModule();

const choices = [];
for (let id of licenseList) {
    choices.push({
        name: licenseFull[id].name,
        value: id,
        short: id
    });
}

export default License;

async function License(options) {
    console.log("options =", options);
    if (options.disabled.includes("license")) return options;

    let questions = [
        {
            message: "Choose a license:",
            type: "list",
            name: "license",
            choices,
            default: options.license,
            paginated: true
        },
        {
            message: "Copyright Holder:",
            type: "input",
            name: "copyrightHolder",
            default: options.copyrightHolder
        }
    ];

    let answers = await prompt(questions);
    let text = licenseFull[answers.license].licenseText;
    text = text.replace("<year>", new Date().getFullYear());
    text = text.replace("<copyright holder>", answers.copyrightHolder);
    fs.writeFileSync("LICENSE.md", text);
    console.log("answers =", answers);

    options.license = answers.license;
    options.copyrightHolder = answers.copyrightHolder;
    return options;
}

if (!module.parent) {
    License();
}
